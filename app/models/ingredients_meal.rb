class IngredientsMeal < ApplicationRecord
  belongs_to :ingredient
  belongs_to :meal

  validates :ingredient, uniqueness: { scope: :meal }
end
