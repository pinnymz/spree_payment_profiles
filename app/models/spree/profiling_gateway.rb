module Spree
  module ProfilingGateway
    def payment_source_class
      PaymentProfile
    end

    def payment_profiles_supported?
      true
    end
  end
end