class ChangeTypeForTimeFieldsInMeal < ActiveRecord::Migration[7.1]
  def change
    change_column :meals, :prep_time, :string
    change_column :meals, :cook_time, :string
    change_column :meals, :total_time, :string
  end
end
