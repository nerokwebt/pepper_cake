class AddNullFalseConstraintToPresenceRequiredColumnsInIngredients < ActiveRecord::Migration[7.1]
  def change
    change_column_null :ingredients, :name, false
  end
end
