# frozen_string_literal: true

class MealsController < ApplicationController
  def index
    @meals = Meal.search_meals(params[:ingredients]&.reject(&:empty?))
    @suggestion_meals = Meal.suggested_meals(params[:ingredients]&.reject(&:empty?))
  end

  def show
    @meal = Meal.find(params[:id])
  end
end
