class ChangeTagsAndIngredientsTypesInMeals < ActiveRecord::Migration[7.1]
  def change
    change_column :meals, :tags, :text
    change_column :meals, :ingredients, :text
  end
end
