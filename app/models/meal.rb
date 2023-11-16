class Meal < ApplicationRecord
  serialize :tags, coder: JSON, type: Array
  serialize :ingredients, coder: JSON, type: Array

  validates :author, :name, :difficulty, :prep_time, :cook_time, :total_time, :people_quantity, :rate, :nb_comments, :image, :tags, :ingredients, presence: true

  validates :name, uniqueness: true
end
