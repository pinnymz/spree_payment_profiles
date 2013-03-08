require 'spec_helper'

describe Spree::GatewayProfile do
  describe "for_gateway scope" do
    let(:klass){ Spree::GatewayProfile }
    before :each do
      user = FactoryGirl.create(:user)
      user.gateway_profiles.create(:gateway => Spree::Gateway::AuthorizeNetCim.to_s, :profile_id => 1000)
      user.gateway_profiles.create(:gateway => Spree::Gateway::Bogus.to_s, :profile_id => 2000)
    end
    it "should return the correct profile by gateway" do
      klass.for_gateway(Spree::Gateway::AuthorizeNetCim).profile_id.should eq(1000.to_s)
      klass.for_gateway(Spree::Gateway::Bogus).profile_id.should eq(2000.to_s)
    end
    it "should return nothing for an unregistered gateway" do
      klass.for_gateway(Spree::Gateway::BogusSimple).should be(nil)
    end
  end
end
