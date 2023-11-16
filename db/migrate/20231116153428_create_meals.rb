class CreateMeals < ActiveRecord::Migration[7.1]
  def change
    create_table :meals do |t|
      t.string :author
      t.string :name
      t.string :difficulty
      t.integer :prep_time
      t.integer :cook_time
      t.integer :total_time
      t.integer :people_quantity
      t.integer :rate
      t.integer :nb_comments
      t.string :image
      t.json :tags
      t.json :ingredients

      t.timestamps
    end
  end
end
