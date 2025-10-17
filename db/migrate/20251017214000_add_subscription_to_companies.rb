class AddSubscriptionToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :subscription_tier, :string, default: 'free'
    add_column :companies, :stripe_customer_id, :string
    add_column :companies, :stripe_subscription_id, :string
    add_column :companies, :subscription_status, :string
    add_column :companies, :trial_ends_at, :datetime
    add_column :companies, :subscription_ends_at, :datetime
    
    add_index :companies, :subscription_tier
    add_index :companies, :stripe_customer_id
    add_index :companies, :stripe_subscription_id
  end
end
