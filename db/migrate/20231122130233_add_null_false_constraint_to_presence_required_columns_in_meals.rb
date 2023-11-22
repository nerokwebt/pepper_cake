class AddNullFalseConstraintToPresenceRequiredColumnsInMeals < ActiveRecord::Migration[7.1]
  def change
    change_column_null :meals, :author, false
    change_column_null :meals, :name, false
    change_column_null :meals, :difficulty, false
    change_column_null :meals, :total_time, false
    change_column_null :meals, :people_quantity, false
    change_column_null :meals, :rate, false
    change_column_null :meals, :nb_comments, false
    change_column_null :meals, :image, false
    change_column_null :meals, :tags, false
    change_column_null :meals, :display_ingredients, false
  end
end
