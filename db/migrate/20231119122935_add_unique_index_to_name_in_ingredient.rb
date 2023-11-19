class AddUniqueIndexToNameInIngredient < ActiveRecord::Migration[7.1]
  def change
    add_index :ingredients, :name, unique: true
  end
end
