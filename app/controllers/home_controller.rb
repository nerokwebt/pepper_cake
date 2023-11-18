class HomeController < ApplicationController
  def index
    @meals = Meal.suggested_meals(params)
  end
end
