class CreateCampsites < ActiveRecord::Migration[8.0]
  def change
    create_table :campsites do |t|
      t.string :name
      t.string :slug
      t.string :about
      t.string :logo
      t.string :primary_colour
      t.string :open_from
      t.string :closed_from
      t.string :website
      t.string :contact_email
      t.string :contact_number

      t.timestamps
    end
  end
end
