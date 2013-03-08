module Spree
  class Gateway::AuthorizeNetCim < Gateway
    include ProfilingGateway
    preference :login, :string
    preference :password, :string
    preference :test_mode, :boolean, :default => false
    preference :validate_on_profile_create, :boolean, :default => false
    preference :hosted, :boolean, :default => false

    attr_accessible :preferred_login, :preferred_password, :preferred_test_mode, :preferred_validate_on_profile_create

    ActiveMerchant::Billing::Response.class_eval do
      attr_writer :authorization
    end

    def provider_class
      self.class
    end

    def options
      # add :test key in the options hash, as that is what the ActiveMerchant::Billing::AuthorizeNetGateway expects
      if self.preferred_test_mode
        self.class.preference :test, :boolean, :default => true
      else
        self.class.remove_preference :test
      end

      super
    end

    def authorize(amount, payment_profile, gateway_options)
      t_options = { :order => {:invoice_number => gateway_options[:order_id] } }
      create_transaction( amount, payment_profile, :auth_only, t_options )
    end

    def purchase(amount, payment_profile, gateway_options)
      create_transaction(amount, payment_profile, :auth_capture)
    end

    def capture(authorization, payment_profile, gateway_options)
      create_transaction((authorization.amount * 100).round, payment_profile, :prior_auth_capture, :trans_id => authorization.response_code)
    end

    def credit(amount, payment_profile, response_code, gateway_options)
      create_transaction(amount, payment_profile, :refund, :trans_id => response_code)
    end

    def void(response_code, payment_profile, gateway_options)
      create_transaction(nil, payment_profile, :void, :trans_id => response_code)
    end

    # Create necessary profiles from a payment via credit card
    def create_profile(payment)
      order = payment.order
      user = order.user
      user_profile = user.gateway_profiles.for_gateway(self.class)
      if user_profile.nil?
        profile_hash = create_customer_profile(user, payment)
        user_profile = user.gateway_profiles.create(:gateway => self.class.to_s, :profile_id => profile_hash[:customer_profile_id])
      end
      payment_hash = create_payment_profile(user_profile, payment)
      user_profile.payment_profiles.create(:profile_id => payment_hash[:customer_payment_profile_id], :description => payment_hash[:payment_descriptor])
    end

    # Update a profile based on new payment info
    def update_profile(payment_profile, payment)
      payment_hash = update_payment_profile(payment_profile, payment)
      payment_profile.update_attributes(:description => payment_hash[:payment_descriptor])
    end

    # Retrieves information for a specific payment profile
    def retrieve_profile(payment_profile)
      get_payment_profile(payment_profile)
    end

    private
# Create a transaction on a payment_profile
# Valid transaction_types are :auth_only, :capture_only, :auth_capture, :prior_auth_capture, :refund, and :void
    def create_transaction(amount, payment_profile, transaction_type, options = {})
      if amount
        amount = "%.2f" % (amount / 100.0) # This gateway requires formated decimal, not cents
      end
      transaction_options = {
          :type => transaction_type,
          :amount => amount,
          :customer_profile_id => payment_profile.gateway_profile.profile_id,
          :customer_payment_profile_id => payment_profile.profile_id,
      }.update(options)
      t = cim_gateway.create_customer_profile_transaction(:transaction => transaction_options)
      logger.debug("\nAuthorize Net CIM Transaction")
      logger.debug("  transaction_options: #{transaction_options.inspect}")
      logger.debug("  response: #{t.inspect}\n")
      t
    end

    # Create a new CIM customer profile ready to accept a payment
    def create_customer_profile(user, payment)
      options = options_for_create_customer_profile(user)
      response = cim_gateway.create_customer_profile(options)
      if response.success?
        { :customer_profile_id => response.params['customer_profile_id'] }
      else
        payment.send(:gateway_error, response)
      end
    end

   def create_payment_profile(user_profile, payment)
      options = options_for_create_payment_profile(user_profile, payment)
      response = cim_gateway.create_customer_payment_profile(options)
      if response.success?
        payment.source.set_last_digits  # hack to ensure 'display_number' works without saving the card
        { :customer_payment_profile_id => response.params['customer_payment_profile_id'], :payment_descriptor => payment.source.display_number }
      else
        payment.send(:gateway_error, response)
      end
   end

    def update_payment_profile(payment_profile, payment)
      options = options_for_create_payment_profile(payment_profile.gateway_profile, payment)
      options[:payment_profile].merge!(:customer_payment_profile_id => payment_profile.profile_id)
      response = cim_gateway.update_customer_payment_profile(options)
      if response.success?
        payment.source.set_last_digits  # hack to ensure 'display_number' works without saving the card
        { :customer_payment_profile_id => response.params['customer_payment_profile_id'], :payment_descriptor => payment.source.display_number }
      else
        payment.send(:gateway_error, response)
      end
    end

    def get_payment_profile(payment_profile)
      options = {:customer_profile_id => payment_profile.gateway_profile.profile_id, :customer_payment_profile_id => payment_profile.profile_id}
      response = cim_gateway.get_customer_payment_profile(options)
      if response.success?
        profile_results = response.params['payment_profile']
        return {} unless profile_results
        {:billing_address => profile_results['bill_to'], :credit_card => profile_results['payment']['credit_card']}
      else
        Payment.new.send(:gateway_error, response)
      end
    end

    def options_for_create_customer_profile(user)
      { :profile => { :merchant_customer_id => "#{Time.now.to_f}-#{user.id}" },
        :validation_mode => validation_mode }
    end

    def options_for_create_payment_profile(user_profile, payment)
      info = { :bill_to => generate_address_hash(payment.order.bill_address), :payment => { :credit_card => payment.source } }

      { :customer_profile_id => user_profile.profile_id,
        :payment_profile => info,
        :validation_mode => validation_mode }
    end

    def validation_mode
      preferred_validate_on_profile_create ? preferred_server.to_sym : :none
    end

    # As in PaymentGateway but with separate name fields
    def generate_address_hash(address)
      return {} if address.nil?
      {:first_name => address.firstname, :last_name => address.lastname, :address1 => address.address1, :address2 => address.address2, :city => address.city,
       :state => address.state_text, :zip => address.zipcode, :country => address.country.iso, :phone => address.phone}
    end

    def cim_gateway
      @gateway ||= -> {
        ActiveMerchant::Billing::Base.gateway_mode = preferred_server.to_sym
        gateway_options = options
        ActiveMerchant::Billing::AuthorizeNetCimGateway.new(gateway_options)
      }.call
    end
  end
end