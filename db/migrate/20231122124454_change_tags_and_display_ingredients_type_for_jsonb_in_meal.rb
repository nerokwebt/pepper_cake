class ChangeTagsAndDisplayIngredientsTypeForJsonbInMeal < ActiveRecord::Migration[7.1]
  def change
    change_column :meals, :tags, :jsonb, using: 'tags::text::jsonb'
    change_column :meals, :display_ingredients, :jsonb, using: 'display_ingredients::text::jsonb'
  end
end
