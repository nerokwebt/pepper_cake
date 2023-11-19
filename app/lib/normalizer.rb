# frozen_string_literal: true

# This class normalizes data extracted from the recipes file, mainly to create ingredients in database used to match the user's search, by
# removing useless information for the search as weight or authors commentaries, helping to get a clean autocomplete. Though, the methods don't
# drop those weights and commentaries and store it in a column instead for display purposes.
class Normalizer < ApplicationRecord
  QUANTITIES_LIST = [
    'b[âa]ton',
    'boc(al|aux)',
    'bol',
    'bo[iî]te',
    'botte',
    'bouquet',
    'bouteille',
    'branche',
    'brin',
    'brique',
    'carr[ée]',
    'centim[eè]tre',
    'cerneau',
    'cube',
    'cuill[èe]res? (à|a|de) ?(caf[ée]|soupe) ?(.*)',
    'demi',
    'extrait',
    'feuille',
    'filet',
    'gousse',
    'goutte',
    'pinc[ée]e',
    'poign[ée]e',
    'pointe',
    'portion',
    'pot',
    'reste',
    'rondelle',
    'rouleau',
    'sachet',
    'sac',
    'tasse',
    'touffe',
    'tube',
    'trait',
    'tranche',
    'verre'
  ].join('|').freeze

  MATCH_QUANTITIES = /\d*? ?(gros(se)?s?|grande?s?|petite?s?)? ?(#{QUANTITIES_LIST})s? d['e]/

  MATCH_BEFORE = [
    %r{(\d+|[0-9]/[0-9]|[0-9]\.[0-9]) ?[m?k]?g d['e]}, %r{(\d+|[0-9]/[0-9]|[0-9]\.[0-9]) ?[m?cd]?l d['e]},
    /\A ?[m?k]?g d['e]/, /\A ?[m?cd]?l d['e]/,
    %r{[0-9]/[0-9]}, /[0-9]\.[0-9]/,
    /\A[^A-Za-zéèêëàâùîïô]*/, /[^A-Za-zéèêëàâùîïô]\z/,
    /^\d+/,
    /\+(.*)/, /\((.*)/, /\)(.*)/, /,(.*)/, /\.(.*)/, %r{/(.*)}, /\\(.*)/, /=(.*)/, /"(.*)/, / -(.*)/, /;(.*)/,
    / et (.*)/, / & ?(.*)/, / ou (.*)/,
    / et\z/, / ou\z/,
    / assez (.*)/,
    / avec (.*)/,
    / bien (.*)/,
    / chacune?s?(.*)/,
    / coupés?(.*)/,
    / d['e] environ (.*)/,
    / dans(.*)/,
    / finement(.*)/,
    / par personne(.*)/,
    / portions?(.*)/,
    / pour (.*)/,
    / soit (.*)/,
    /(à|a|selon) ?(votre)? (convenance|volonté)(.*)/,
    /[de ]?\d+ ?[m?k]?g? [aà]? \d+ ?[m?k]?g(.*)/,
    /[de ]?\d+ ?[m?k]?g(.*)/,
    /[de ]?\d+ ?[m?cd]?l? [aà]? \d+ ?[m?cd]?l(.*)/,
    /[de ]?\d+ ?[m?cd]?l(.*)/,
    /(a|à) ?\d+% ?(de)?(.*)/
  ].freeze

  MATCH_AFTER = [
    / (d['e])? ?\d+(.*)\z/,
    /n°(.*)/, / n\z/
  ].freeze

  MATCH_LAST = [
    / d['e]? ?\z/,
    / .\z/
  ].freeze

  # Reads the json file to populate database
  def self.parse(file_path)
    File.readlines(file_path).each do |line|
      meal_attributes = JSON.parse(line)

      # Can't use meals without an image in app
      next if meal_attributes['image'].blank?

      # Removes the attributes we are not using in the app
      meal_attributes.except!('author_tip', 'budget')

      # Renames column so we can differentiate Ingredients association for ingredients stored in Meal column in database
      meal_attributes['display_ingredients'] = meal_attributes.delete('ingredients').uniq

      ingredients_meals_attributes = Normalizer.normalize_ingredients(meal_attributes['display_ingredients'])

      # Creates a meal in database with all prepared attributes and nested attributes
      next unless ingredients_meals_attributes.any?

      meal_attributes[:ingredients_meals_attributes] = ingredients_meals_attributes.uniq
      meal_attributes = Normalizer.normalize_meal(meal_attributes)

      Normalizer.populate_db(meal_attributes, Meal)
    end

    puts 'Meals generated!'
  end

  # Normalizes ingredients by removing weight and/or useless information for the database
  def self.normalize_ingredients(ingredients)
    ingredients_meals_attributes = []

    ingredients.each do |ingredient|
      ingredient_attributes = Normalizer.match_ingredient(ingredient)

      created_ingredient = Normalizer.populate_db(ingredient_attributes, Ingredient) if ingredient_attributes[:name].present?

      # Prepares a hash to create IngredientsMeal with new or match already created Ingredient for current Meal
      ingredients_meals_attributes << { ingredient_id: created_ingredient.id || Ingredient.where(name: created_ingredient.name).first.id } if created_ingredient
    end

    ingredients_meals_attributes
  end

  # Matches regex patterns defined as constants to normalize the ingredient
  def self.match_ingredient(ingredient)
    # Never use ! on methods here or it will modify the reference as well, which is the displayed_attributes column we don't want to change

    # Normalises case, whitespaces and special characters to manipulate easier
    ingredient = ingredient.downcase
    ingredient = ingredient.strip
    ingredient = ingredient.gsub('’', '\'')

    # Matches our constants to remove useless informations like weight, commentaries, etc
    ingredient = ingredient.gsub(Regexp.union(MATCH_BEFORE), '')
    ingredient = ingredient.gsub(/#{MATCH_QUANTITIES}/, '')
    ingredient = ingredient.gsub(Regexp.union(MATCH_AFTER), '')
    ingredient = ingredient.gsub(Regexp.union(MATCH_LAST), '')

    # Replaces all multiple spaces at once by only one space
    ingredient = ingredient.gsub(/\s+/, ' ')
    ingredient = ingredient.strip

    # Returns a hash that can be used to create a new Ingredient
    { name: ingredient }
  end

  # Creates the object in database
  def self.populate_db(attributes, object_class)
    object = object_class.create(attributes)

    puts "Created #{object_class} #{object.name}"

    object
  end

  # Transforms all time values as string into integers
  def self.normalize_meal(meal_attributes)
    %w[prep_time cook_time total_time].each do |attribute|
      meal_attributes[attribute] = Normalizer.convert_time_string_to_seconds(meal_attributes[attribute])
    end

    meal_attributes
  end

  # Transforms every time value indicated as a string in the json file into an time value in seconds as an integer, for the database
  def self.convert_time_string_to_seconds(time)
    time_array = []

    %w[j h min].each do |duration_type|
      next unless time && duration_type.in?(time)

      split_time = Normalizer.get_seconds_nb_from_duration_type(duration_type, time)

      # We store the processed value
      time_array << split_time[:processed_value]

      # We only reiterate on the remaining unprocessed values
      time = split_time[:remaining_value]
    end

    time_array.inject(:+)
  end

  # Transforms a string into an integer in seconds regarding its duration_type (days, hours or minutes)
  def self.get_seconds_nb_from_duration_type(duration_type, time)
    split_time = time.split(duration_type)

    # We send a different method regarding the duration_type (days, hours or minutes)
    case duration_type
    when 'j'
      time_method = 'days'
    when 'h'
      time_method = 'hours'
    when 'min'
      time_method = 'minutes'
    end

    # We return two values, the already processed values and the remaining unprocessed values we need to reiterate on
    { processed_value: split_time.first.to_i.send(time_method).to_i, remaining_value: split_time.try(:second) }
  end
end
