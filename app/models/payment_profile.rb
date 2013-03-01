module Spree
  class PaymentProfile < ActiveRecord::Base
    attr_accessible :profile_id, :description, :default
    belongs_to :gateway_profile, :inverse_of => :payment_profiles
    has_many :payments, :as => :source
  end
end
