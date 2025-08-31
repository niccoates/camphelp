# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_31_175313) do
  create_table "campsite_users", force: :cascade do |t|
    t.integer "campsite_id", null: false
    t.integer "user_id", null: false
    t.boolean "is_owner", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campsite_id", "user_id"], name: "index_campsite_users_on_campsite_id_and_user_id", unique: true
    t.index ["campsite_id"], name: "index_campsite_users_on_campsite_id"
    t.index ["user_id"], name: "index_campsite_users_on_user_id"
  end

  create_table "campsites", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "about"
    t.string "logo"
    t.string "primary_colour"
    t.string "open_from"
    t.string "closed_from"
    t.string "website"
    t.string "contact_email"
    t.string "contact_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_subscription_id"
    t.string "subscription_status"
    t.datetime "trial_ends_at"
    t.index ["stripe_subscription_id"], name: "index_campsites_on_stripe_subscription_id", unique: true
    t.index ["subscription_status"], name: "index_campsites_on_subscription_status"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone"
    t.string "stripe_customer_id"
    t.boolean "has_used_trial", default: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
  end

  add_foreign_key "campsite_users", "campsites"
  add_foreign_key "campsite_users", "users"
  add_foreign_key "sessions", "users"
end
