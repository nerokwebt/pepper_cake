# frozen_string_literal: true

class Meal < ApplicationRecord
  serialize :tags, coder: JSON, type: Array
  serialize :ingredients, coder: JSON, type: Array

  has_many :ingredients_meals, dependent: :destroy
  has_many :ingredients, through: :ingredients_meals

  accepts_nested_attributes_for :ingredients_meals

  validates :author, :name, :difficulty, :prep_time, :cook_time, :total_time, :people_quantity, :rate, :nb_comments, :image, :tags, :display_ingredients, :ingredients_meals, presence: true

  validates :name, uniqueness: true

  def self.meals_w_one_ingredient(ingredients)
    Meal.joins(ingredients_meals: :ingredient).where(ingredients_meals: { ingredient: ingredients })
  end

  def self.search_meals(ingredients_names)
    if ingredients_names&.any?
      ingredients = Ingredient.where(name: ingredients_names.reject(&:empty?))
      meals_w_one_ingredient = meals_w_one_ingredient(ingredients)

      meals_to_exclude = Meal.joins(:ingredients_meals)
        .where(id: meals_w_one_ingredient.pluck(:id))
        .where.not('ingredients_meals.ingredient_id': ingredients.pluck(:id))

      Meal.where(id: meals_w_one_ingredient.pluck(:id))
        .where.not(id: meals_to_exclude.pluck(:id))
    end
  end

  def self.suggested_meals(ingredients_names)
    if ingredients_names&.any?
      ingredients = Ingredient.where(name: ingredients_names.reject(&:empty?))
      Meal.meals_w_one_ingredient(ingredients).order(rate: :desc).first(30).sample(5)
    else
      raise 'toto'
      Meal.where('nb_comments > ?', 30).where('rate > ?', 4.6).sample(5)
    end
  end
end
