class CreatePaymentProfiles < ActiveRecord::Migration
  def change
    create_table :gateway_profiles do |t|
      t.integer :user_id, :null => false
      t.string :gateway, :null => false
      t.string :profile_id, :null => false
      t.boolean :expired
      t.timestamps
    end

    create_table :payment_profiles do |t|
      t.references :gateway_profile, :null => false
      t.string :profile_id, :null => false
      t.string :description, :null => false
      t.boolean :default
      t.boolean :expired
      t.timestamps
    end
  end
end
