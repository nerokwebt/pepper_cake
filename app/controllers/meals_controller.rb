class MealsController < ApplicationController
  def index
    @meals = Meal.search(params)
  end

  def show
    @meal = Meal.find(params[:id])
  end
end
