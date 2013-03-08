# responses copied from https://github.com/Shopify/active_merchant/blob/master/test/unit/gateways/authorize_net_cim_test.rb
module ResponseHelpers
  def setup
    @am_gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
        :login => 'X',
        :password => 'Y'
    )
    @amount = 100
    @credit_card = credit_card
    @customer_profile_id = '3187'
    @customer_payment_profile_id = '7813'
    @payment = {
        :credit_card => @credit_card
    }
    @profile = {
        :merchant_customer_id => 'Up to 20 chars'
    }
    @options = {
        :ref_id => '1234', # Optional
        :profile => @profile
    }
  end

  def successful_create_customer_profile_response
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <createCustomerProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <customerProfileId>#{@customer_profile_id}</customerProfileId>
      </createCustomerProfileResponse>
    XML
  end

  def successful_create_customer_payment_profile_response
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <createCustomerPaymentProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <customerPaymentProfileId>#{@customer_payment_profile_id}</customerPaymentProfileId>
        <validationDirectResponse>This output is only present if the ValidationMode input parameter is passed with a value of testMode or liveMode</validationDirectResponse>
      </createCustomerPaymentProfileResponse>
    XML
  end

  def successful_get_customer_payment_profile_response
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <getCustomerPaymentProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <profile>
          <paymentProfiles>
            <customerPaymentProfileId>#{@customer_payment_profile_id}</customerPaymentProfileId>
            <payment>
              <creditCard>
                  <cardNumber>#{@credit_card.number}</cardNumber>
                  <expirationDate>#{@gateway.send(:expdate, @credit_card)}</expirationDate>
              </creditCard>
            </payment>
          </paymentProfiles>
        </profile>
      </getCustomerPaymentProfileResponse>
    XML
  end

  def successful_update_customer_payment_profile_response
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <updateCustomerPaymentProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
      </updateCustomerPaymentProfileResponse>
    XML
  end

  SUCCESSFUL_DIRECT_RESPONSE = {
      :auth_only => '1,1,1,This transaction has been approved.,Gw4NGI,Y,508223659,,,100.00,CC,auth_only,Up to 20 chars,,,,,,,,,,,Up to 255 Characters,,,,,,,,,,,,,,6E5334C13C78EA078173565FD67318E4,,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,',
      :capture_only => '1,1,1,This transaction has been approved.,,Y,508223660,,,100.00,CC,capture_only,Up to 20 chars,,,,,,,,,,,Up to 255 Characters,,,,,,,,,,,,,,6E5334C13C78EA078173565FD67318E4,,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,',
      :auth_capture => '1,1,1,This transaction has been approved.,d1GENk,Y,508223661,32968c18334f16525227,Store purchase,1.00,CC,auth_capture,,Longbob,Longsen,,,,,,,,,,,,,,,,,,,,,,,269862C030129C1173727CC10B1935ED,M,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,',
      :void => '1,1,1,This transaction has been approved.,nnCMEx,P,2149222068,1245879759,,0.00,CC,void,1245879759,,,,,,,K1C2N6,,,,,,,,,,,,,,,,,,F240D65BB27ADCB8C80410B92342B22C,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,',
      :refund => '1,1,1,This transaction has been approved.,nnCMEx,P,2149222068,1245879759,,0.00,CC,refund,1245879759,,,,,,,K1C2N6,,,,,,,,,,,,,,,,,,F240D65BB27ADCB8C80410B92342B22C,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,',
      :prior_auth_capture => '1,1,1,This transaction has been approved.,VR0lrD,P,2149227870,1245958544,,1.00,CC,prior_auth_capture,1245958544,,,,,,,K1C2N6,,,,,,,,,,,,,,,,,,0B8BFE0A0DE6FDB69740ED20F79D04B0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,',
      :auth_capture_version_3_1 => '1,1,1,This transaction has been approved.,CSYM0K,Y,2163585627,1234,Test Order Description,100.00,CC,auth_capture,Up to 20 chars,,,Widgets Inc,1234 My Street,Ottawa,ON,K1C2N6,CA,,,Up to 255 Characters,,,,,,,,,,,,,4321,02DFBD7934AD862AB16688D44F045D31,,2,,,,,,,,,,,XXXX4242,Visa,,,,,,,,,,,,,,,,'
  }
  UNSUCCESSUL_DIRECT_RESPONSE = {
      :refund => '3,2,54,The referenced transaction does not meet the criteria for issuing a credit.,,P,0,,,1.00,CC,credit,1245952682,,,Widgets Inc,1245952682 My Street,Ottawa,ON,K1C2N6,CA,,,bob1245952682@email.com,,,,,,,,,,,,,,207BCBBF78E85CF174C87AE286B472D2,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,447250,406104'
  }

  def successful_create_customer_profile_transaction_response(transaction_type)
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?> 
      <createCustomerProfileTransactionResponse 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"> 
        <refId>refid1</refId> 
        <messages> 
          <resultCode>Ok</resultCode> 
          <message> 
            <code>I00001</code> 
            <text>Successful.</text> 
          </message> 
        </messages> 
        <directResponse>#{SUCCESSFUL_DIRECT_RESPONSE[transaction_type]}</directResponse>
      </createCustomerProfileTransactionResponse>
    XML
  end

  def successful_validate_customer_payment_profile_response
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?> 
      <validateCustomerPaymentProfileResponse 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"> 
        <refId>refid1</refId> 
        <messages> 
          <resultCode>Ok</resultCode> 
          <message> 
            <code>I00001</code> 
            <text>Successful.</text> 
          </message> 
        </messages> 
        <directResponse>1,1,1,This transaction has been approved.,DEsVh8,Y,508276300,none,Test transaction for ValidateCustomerPaymentProfile.,0.01,CC,auth_only,Up to 20 chars,,,,,,,,,,,Up to 255 Characters,John,Doe,Widgets, Inc,1234 Fake Street,Anytown,MD,12345,USA,0.0000,0.0000,0.0000,TRUE,none,7EB3A44624C0C10FAAE47E276B48BF17,,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,</directResponse>
      </validateCustomerPaymentProfileResponse>
    XML
  end

  def unsuccessful_create_customer_profile_transaction_response(transaction_type)
    <<-XML
      <?xml version="1.0" encoding="utf-8"?>
      <createCustomerProfileTransactionResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <messages>
          <resultCode>Error</resultCode>
          <message>
            <code>E00027</code>
            <text>The transaction was unsuccessful.</text>
          </message>
        </messages>
        <directResponse>#{UNSUCCESSUL_DIRECT_RESPONSE[transaction_type]}</directResponse>
      </createCustomerProfileTransactionResponse>
    XML
  end

  private
  def credit_card(number = '4242424242424242', options = {})
    defaults = {
        :number => number,
        :month => 9,
        :year => Time.now.year + 1,
        :first_name => 'Longbob',
        :last_name => 'Longsen',
        :verification_value => '123',
        :brand => 'visa'
    }.update(options)

    ActiveMerchant::Billing::CreditCard.new(defaults)
  end

end