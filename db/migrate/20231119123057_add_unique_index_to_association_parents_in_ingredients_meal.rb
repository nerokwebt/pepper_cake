class AddUniqueIndexToAssociationParentsInIngredientsMeal < ActiveRecord::Migration[7.1]
  def change
    add_index :ingredients_meals, [:ingredient_id, :meal_id], unique: true
  end
end
