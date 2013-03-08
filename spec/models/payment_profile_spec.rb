require 'spec_helper'

describe Spree::PaymentProfile do
  describe "defaults" do
    describe "when creating an initial profile" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @gateway_profile = @user.gateway_profiles.create(:gateway => Spree::Gateway::Bogus.to_s, :profile_id => 1000)
        @profile1 = @gateway_profile.payment_profiles.create(:profile_id => 2000, :description => 'XXXX4242')
      end
      it "should have default set to true" do
        @profile1.default?.should be(true)
      end
      describe "and a second for the same user" do
        before :each do
          @profile2 = @gateway_profile.payment_profiles.create(:profile_id => 2001, :description => 'XXXX5353')
        end
        it "should not become default" do
          @profile2.default?.should_not be(true)
        end
        it "should leave the original as default" do
          @profile1.reload.default?.should be(true)
        end
      end
      describe "and a second for another user" do
        before :each do
          @user2 = FactoryGirl.create(:user)
          @gateway_profile2 = @user2.gateway_profiles.create(:gateway => Spree::Gateway::Bogus.to_s, :profile_id => 1000)
          @profile2 = @gateway_profile2.payment_profiles.create(:profile_id => 2001, :description => 'XXXX5353')
        end
        it "should make both default" do
          @profile2.default?.should be(true)
          @profile1.reload.default?.should be(true)
        end
      end
    end
  end
end
