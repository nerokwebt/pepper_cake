class RenameIngredientsInDisplayIngredientsInMeals < ActiveRecord::Migration[7.1]
  def change
    rename_column :meals, :ingredients, :display_ingredients
  end
end
