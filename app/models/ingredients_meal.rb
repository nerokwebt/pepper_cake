# frozen_string_literal: true

class IngredientsMeal < ApplicationRecord
  belongs_to :ingredient
  belongs_to :meal

  validates :ingredient, uniqueness: { scope: :meal }
end
