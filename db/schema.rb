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

ActiveRecord::Schema[8.0].define(version: 2026_08_16_080054) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "check_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "quantity", null: false
    t.uuid "check_id", null: false
    t.uuid "order_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_id"], name: "index_check_items_on_check_id"
    t.index ["order_item_id"], name: "index_check_items_on_order_item_id"
  end

  create_table "checks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "subtotal_cents", default: 0, null: false
    t.bigint "tax_cents", default: 0, null: false
    t.bigint "tip_cents", default: 0, null: false
    t.integer "status", default: 1, null: false
    t.uuid "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_checks_on_order_id"
  end

  create_table "commerces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "theme", default: "light", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "floor_zones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.uuid "commerce_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commerce_id", "position"], name: "index_floor_zones_on_commerce_id_and_position"
  end

  create_table "modifier_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_required", default: false, null: false
    t.integer "min_selected", default: 0, null: false
    t.integer "max_selected"
    t.uuid "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_modifier_groups_on_product_id"
  end

  create_table "modifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.bigint "price_delta_cents", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.uuid "modifier_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["modifier_group_id"], name: "index_modifiers_on_modifier_group_id"
  end

  create_table "order_item_modifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "modifier_group_name", null: false
    t.string "modifier_name", null: false
    t.bigint "price_delta_cents", default: 0, null: false
    t.uuid "order_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_item_id"], name: "index_order_item_modifiers_on_order_item_id"
  end

  create_table "order_item_variants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "variant_group_name", null: false
    t.string "variant_name", null: false
    t.bigint "price_delta_cents", default: 0, null: false
    t.uuid "order_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_item_id"], name: "index_order_item_variants_on_order_item_id"
  end

  create_table "order_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "base_price_cents", null: false
    t.datetime "fired_at"
    t.string "product_name", null: false
    t.integer "quantity", null: false
    t.text "notes"
    t.uuid "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "opened_at", null: false
    t.datetime "closed_at"
    t.integer "status", default: 1, null: false
    t.uuid "table_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["table_id"], name: "index_orders_on_table_id"
    t.index ["table_id"], name: "index_orders_on_table_id_when_open", unique: true, where: "(status = 1)"
  end

  create_table "product_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "icon", null: false
    t.uuid "commerce_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commerce_id", "name"], name: "index_product_categories_on_commerce_id_and_name", unique: true
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_active", default: true, null: false
    t.bigint "base_price_cents", null: false
    t.uuid "commerce_id", null: false
    t.uuid "product_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commerce_id", "is_active"], name: "index_products_on_commerce_id_and_is_active"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
  end

  create_table "tables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "capacity", null: false
    t.integer "number", null: false
    t.integer "pos_x", default: 0, null: false
    t.integer "pos_y", default: 0, null: false
    t.integer "width", default: 2, null: false
    t.integer "height", default: 2, null: false
    t.integer "status", default: 1, null: false
    t.uuid "commerce_id", null: false
    t.uuid "floor_zone_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commerce_id", "number"], name: "index_tables_on_commerce_id_and_number", unique: true
    t.index ["floor_zone_id"], name: "index_tables_on_floor_zone_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.string "locale", null: false
    t.integer "role", null: false
    t.uuid "commerce_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commerce_id"], name: "index_users_on_commerce_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variant_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_required", default: false, null: false
    t.uuid "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_variant_groups_on_product_id"
  end

  create_table "variants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "sku", null: false
    t.bigint "price_delta_cents", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.uuid "variant_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["variant_group_id"], name: "index_variants_on_variant_group_id"
  end

  add_foreign_key "check_items", "checks"
  add_foreign_key "check_items", "order_items"
  add_foreign_key "checks", "orders"
  add_foreign_key "floor_zones", "commerces"
  add_foreign_key "modifier_groups", "products"
  add_foreign_key "modifiers", "modifier_groups"
  add_foreign_key "order_item_modifiers", "order_items"
  add_foreign_key "order_item_variants", "order_items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "tables"
  add_foreign_key "product_categories", "commerces"
  add_foreign_key "products", "commerces"
  add_foreign_key "products", "product_categories"
  add_foreign_key "tables", "commerces"
  add_foreign_key "tables", "floor_zones"
  add_foreign_key "users", "commerces"
  add_foreign_key "variant_groups", "products"
  add_foreign_key "variants", "variant_groups"
end
