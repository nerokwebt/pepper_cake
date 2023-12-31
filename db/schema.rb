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

ActiveRecord::Schema[7.1].define(version: 2023_11_22_130747) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "ingredients_meals", force: :cascade do |t|
    t.bigint "ingredient_id", null: false
    t.bigint "meal_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id", "meal_id"], name: "index_ingredients_meals_on_ingredient_id_and_meal_id", unique: true
    t.index ["ingredient_id"], name: "index_ingredients_meals_on_ingredient_id"
    t.index ["meal_id"], name: "index_ingredients_meals_on_meal_id"
  end

  create_table "meals", force: :cascade do |t|
    t.string "author", null: false
    t.string "name", null: false
    t.string "difficulty", null: false
    t.string "total_time", null: false
    t.integer "people_quantity", null: false
    t.float "rate", null: false
    t.integer "nb_comments", null: false
    t.string "image", null: false
    t.jsonb "tags", null: false
    t.jsonb "display_ingredients", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_meals_on_name", unique: true
  end

  add_foreign_key "ingredients_meals", "ingredients"
  add_foreign_key "ingredients_meals", "meals"
end
