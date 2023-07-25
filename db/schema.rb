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

ActiveRecord::Schema[7.0].define(version: 2023_07_23_190713) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.jsonb "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.string "cat_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "price_id", null: false
    t.jsonb "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_diff"
    t.integer "price_percent"
    t.boolean "notify", default: false
    t.index ["price_id"], name: "index_discounts_on_price_id"
    t.index ["product_id"], name: "index_discounts_on_product_id"
  end

  create_table "prices", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.jsonb "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_prices_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.jsonb "data", default: {}
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sku"
    t.jsonb "webapi_data", default: {}
    t.boolean "parsed", default: false
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "chat_id"
    t.string "username"
    t.string "first_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "discounts", "prices"
  add_foreign_key "discounts", "products"
  add_foreign_key "prices", "products"
  add_foreign_key "products", "categories"
end
