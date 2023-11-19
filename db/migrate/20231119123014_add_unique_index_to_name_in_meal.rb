class AddUniqueIndexToNameInMeal < ActiveRecord::Migration[7.1]
  def change
    add_index :meals, :name, unique: true
  end
end
