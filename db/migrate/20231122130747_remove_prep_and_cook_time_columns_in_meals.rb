class RemovePrepAndCookTimeColumnsInMeals < ActiveRecord::Migration[7.1]
  def change
    remove_column :meals, :prep_time
    remove_column :meals, :cook_time
  end
end
