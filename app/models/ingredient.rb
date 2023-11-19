class Ingredient < ApplicationRecord
  has_many :ingredients_meals, dependent: :destroy
  has_many :meals, through: :ingredients_meals

  validates :name, presence: true
  validates :name, uniqueness: true
end
