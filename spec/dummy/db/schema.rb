# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_30_204816) do

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
