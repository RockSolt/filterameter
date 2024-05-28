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

ActiveRecord::Schema[7.1].define(version: 2024_05_28_221556) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brands", force: :cascade do |t|
    t.bigint "vendor_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_id"], name: "index_brands_on_vendor_id"
  end

  create_table "prices", force: :cascade do |t|
    t.bigint "shirt_id"
    t.decimal "current", precision: 10, scale: 2
    t.decimal "original", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shirt_id"], name: "index_prices_on_shirt_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.integer "priority"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shirts", force: :cascade do |t|
    t.bigint "brand_id"
    t.string "color"
    t.string "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_shirts_on_brand_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.integer "ship_time_in_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "brands", "vendors"
  add_foreign_key "prices", "shirts"
  add_foreign_key "shirts", "brands"
end
