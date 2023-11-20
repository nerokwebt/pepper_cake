# frozen_string_literal: true

class MealsController < ApplicationController
  def index
    @meals = Meal.search_meals(params[:ingredients])
    @suggested_meals = Meal.order(:rate).first(5)
  end

  def show
    @meal = Meal.find(params[:id])
  end
end