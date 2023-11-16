class ChangeRateTypeInMeals < ActiveRecord::Migration[7.1]
  def change
    change_column :meals, :rate, :float
  end
end
