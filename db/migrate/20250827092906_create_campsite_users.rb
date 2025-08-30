# db/migrate/xxx_create_campsite_users.rb
class CreateCampsiteUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :campsite_users do |t|
      t.references :campsite, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :is_owner, default: false

      t.timestamps
    end

    add_index :campsite_users, [ :campsite_id, :user_id ], unique: true
  end
end
