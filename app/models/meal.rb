# frozen_string_literal: true

class Meal < ApplicationRecord
  serialize :tags, coder: JSON, type: Array
  serialize :display_ingredients, coder: JSON, type: Array

  has_many :ingredients_meals, dependent: :destroy
  has_many :ingredients, through: :ingredients_meals

  accepts_nested_attributes_for :ingredients_meals

  validates :author, :name, :difficulty, :prep_time, :cook_time, :total_time, :people_quantity, :rate, :nb_comments,
            :image, :tags, :display_ingredients, :ingredients_meals, presence: true

  validates :name, uniqueness: true

  scope :random_suggested_meals, -> { where('nb_comments > ?', 30).where('rate > ?', 4.6) }

  def self.meals_w_one_ingredient(ingredients)
    Meal.joins(ingredients_meals: :ingredient)
        .where(ingredients_meals: { ingredient: ingredients })
  end

  def self.search_meals(ingredients_names)
    return unless ingredients_names&.any?

    ingredients = Ingredient.where(name: ingredients_names)
    meals_w_one_ingredient = meals_w_one_ingredient(ingredients)

    meals_to_exclude = Meal.joins(ingredients_meals: :ingredient)
                           .where(id: meals_w_one_ingredient(ingredients).select(:id))
                           .where.not(ingredients_meals: { ingredient: ingredients })

    Meal.where(id: meals_w_one_ingredient.select(:id))
        .where.not(id: meals_to_exclude.select(:id))
        .order(rate: :desc).first(10)
  end

  def self.suggested_meals(ingredients_names)
    if ingredients_names&.any?
      ingredients = Ingredient.where(name: ingredients_names)
      suggested_meals = Meal.meals_w_one_ingredient(ingredients).order(rate: :desc)

      if suggested_meals.count >= 6
        suggested_meals.distinct.first(30).sample(6)
      else
        suggested_meals.or(random_suggested_meals).distinct.first(30).sample(6)
      end
    else
      random_suggested_meals.distinct.sample(6)
    end
  end
end
