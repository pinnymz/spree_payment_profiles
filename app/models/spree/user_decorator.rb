(Spree.user_class || Spree::User).class_eval do
  has_many :gateway_profiles, :inverse_of => :user, :foreign_key => :user_id, :dependent => :destroy
end