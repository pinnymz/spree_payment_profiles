module Spree
  class GatewayProfile < ActiveRecord::Base
    attr_accessible :gateway, :profile_id
    if Spree.user_class
      belongs_to :user, :class_name => Spree.user_class.to_s, :inverse_of => :gateway_profiles
    else
      belongs_to :user, :inverse_of => :gateway_profiles
    end
    has_many :payment_profiles, :inverse_of => :gateway_profile, :dependent => :destroy
  end
end
