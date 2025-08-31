class AddStripeFieldsToCampsites < ActiveRecord::Migration[7.0]
  def change
    add_column :campsites, :stripe_subscription_id, :string
    add_column :campsites, :subscription_status, :string
    add_column :campsites, :trial_ends_at, :datetime

    add_index :campsites, :stripe_subscription_id, unique: true
    add_index :campsites, :subscription_status
  end
end
