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

ActiveRecord::Schema[7.1].define(version: 2023_11_16_155737) do
  create_table "meals", force: :cascade do |t|
    t.string "author"
    t.string "name"
    t.string "difficulty"
    t.integer "prep_time"
    t.integer "cook_time"
    t.integer "total_time"
    t.integer "people_quantity"
    t.integer "rate"
    t.integer "nb_comments"
    t.string "image"
    t.text "tags"
    t.text "ingredients"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
