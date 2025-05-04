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

ActiveRecord::Schema[8.0].define(version: 2025_05_04_141428) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_tokens_on_token"
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "appliances", force: :cascade do |t|
    t.string "name", null: false
    t.string "brand", null: false
    t.string "model", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
  end

  create_table "availabilities", force: :cascade do |t|
    t.time "start_time"
    t.time "end_time"
    t.integer "day_of_week"
    t.bigint "repairer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repairer_id"], name: "index_availabilities_on_repairer_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "status"
    t.text "address"
    t.text "notes"
    t.bigint "repairer_id", null: false
    t.bigint "user_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repairer_id"], name: "index_bookings_on_repairer_id"
    t.index ["service_id"], name: "index_bookings_on_service_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.text "content"
    t.string "sender_type", null: false
    t.bigint "sender_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_messages_on_booking_id"
    t.index ["sender_type", "sender_id"], name: "index_messages_on_sender"
  end

  create_table "repairers", force: :cascade do |t|
    t.decimal "hourly_rate"
    t.integer "service_radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "address", default: ""
    t.boolean "professional"
    t.integer "years_experience"
    t.float "ratings_average"
    t.integer "reviews_count"
    t.integer "clients_count"
    t.text "bio"
    t.string "profile_picture_id"
    t.jsonb "work_image_ids", default: [], null: false
    t.index ["email_address"], name: "index_repairers_on_email_address", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "rating"
    t.text "comment"
    t.bigint "user_id", null: false
    t.bigint "repairer_id", null: false
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id"
    t.index ["repairer_id"], name: "index_reviews_on_repairer_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "duration_minutes"
    t.decimal "base_price"
    t.bigint "repairer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "appliance_id", null: false
    t.index ["appliance_id"], name: "index_services_on_appliance_id"
    t.index ["repairer_id"], name: "index_services_on_repairer_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
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
    t.string "name", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "address", default: ""
    t.boolean "onboarded", default: false
    t.date "date_of_birth"
    t.string "mobile_number"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "api_tokens", "users"
  add_foreign_key "availabilities", "repairers"
  add_foreign_key "bookings", "repairers"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "users"
  add_foreign_key "messages", "bookings"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "repairers"
  add_foreign_key "reviews", "users"
  add_foreign_key "services", "appliances"
  add_foreign_key "services", "repairers"
  add_foreign_key "sessions", "users"
end
