module Spree
  class PaymentProfile < ActiveRecord::Base
    attr_accessible :profile_id, :description, :default
    belongs_to :gateway_profile, :inverse_of => :payment_profiles
    has_many :payments, :as => :source

    before_create :init_default

    private
    def init_default
      self.default = true if gateway_profile.payment_profiles.count == 0
    end
  end
end
