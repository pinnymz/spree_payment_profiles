require 'spec_helper'
require 'models/gateway/authorize_net_cim_helper'

RSpec.configure do |c|
  c.include ResponseHelpers
end

describe Spree::Gateway::AuthorizeNetCim do
  before :each do
    setup
  end
  let(:gateway){ Spree::Gateway::AuthorizeNetCim.new }
  describe "options" do
    it "should include :test => true when :test_mode is true" do
      gateway.preferred_test_mode = true
      gateway.options[:test].should == true
    end

    it "should not include :test when :test_mode is false" do
      gateway.preferred_test_mode = false
      gateway.options[:test].should be_nil
    end
  end

  describe "create_profile" do
    before :each do
      @user = FactoryGirl.create(:user)
      @order = FactoryGirl.create(:order, :user => @user)
      @credit_card = FactoryGirl.build(:credit_card)
      @payment = FactoryGirl.create(:payment, :order => @order, :source => @credit_card)
      ActiveMerchant::Billing::AuthorizeNetCimGateway.any_instance.
          should_receive(:ssl_post).and_return(successful_create_customer_profile_response, successful_create_customer_payment_profile_response)
    end
    it 'should create user and payment profiles' do
      profile = gateway.create_profile(@payment)
      gp = @user.gateway_profiles.for_gateway(gateway.class)
      gp.should_not be(nil)
      gp.payment_profiles.count.should be(1)
      profile.class.should be(Spree::PaymentProfile)
    end
  end
end