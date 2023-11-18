class Meal < ApplicationRecord
  serialize :tags, coder: JSON, type: Array
  serialize :ingredients, coder: JSON, type: Array

  validates :author, :name, :difficulty, :prep_time, :cook_time, :total_time, :people_quantity, :rate, :nb_comments, :image, :tags, :ingredients, presence: true

  validates :name, uniqueness: true

  def self.suggested_meals attributes
    puts "TOTO SUGGESTED"
    puts attributes
    Meal.where(name: "Wrap aux légumes d'été et feta")
  end

  def self.search attributes
    puts "TOTO SEARCH"
    puts attributes
    Meal.where(name: "Wrap aux légumes d'été et feta")
  end
end
