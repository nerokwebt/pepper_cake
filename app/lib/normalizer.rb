class Normalizer < ApplicationRecord
  # Reads the json file to populate database
  def self.parse file_path
    ingredients = []

    File.readlines(file_path).each do |line|
      meal_attributes = JSON.parse(line)

      # Removes the attributes we are not using in the app
      meal_attributes.except!('author_tip', 'budget')

      Normalizer.create_meals(meal_attributes)
    end

    puts "Meals generated!"
  end

  # # LEGACY METHOD
  # def self.normalize_ingredient ingredient
  #   quantities = [/[0-9]\/[0-9]/,
  #     /\d+mg d'/, /\d+mg de/, /\d+kg d'/, /\d+kg de/, /\d+g d'/, /\d+g de/, /^\d+/,
  #     /poignées? d['e]/,
  #     /pincées? d['e]/,
  #     /cuillères? à café d['e]/,
  #     /cuillères? à soupe d['e]/,]

  #   ingredient.gsub!(Regexp.union(quantities), '')
  #   ingredient.strip!
  #   { name: ingredient }
  # end

  def self.create_meals meal_attributes
    # Will transform all time values as string into integers
    ['prep_time', 'cook_time', 'total_time'].each do |attribute|
      meal_attributes[attribute] = Normalizer.convert_time_string_to_seconds(meal_attributes[attribute])
    end

    Normalizer.populate_db(meal_attributes, Meal)
  end

  # Creates the object in database
  def self.populate_db attributes, object_class
    object = object_class.create(attributes)
    
    puts "Created #{object_class.to_s} #{object.name}"

    object
  end

  # Will transform every time value indicated as a string in the json file into an time value in seconds as an integer, for the database
  def self.convert_time_string_to_seconds(time)
    time_array = []

    ['j', 'h', 'min'].each do |duration_type|
      if time and duration_type.in?(time)
        split_time = Normalizer.get_seconds_nb_from_duration_type(duration_type, time)

        # We store the processed value
        time_array << split_time.second
        # We only reiterate on the remaining unprocessed values
        time = split_time.first
      end
    end

    time_array.inject(:+)
  end

  # Will transform a string into an integer in seconds regarding its duration_type (days, hours or minutes)
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

    # We return two values, the remaining unprocessed values we need to reiterate on and the processed ones
    [split_time.try(:second), split_time.first.to_i.send(time_method).to_i]
  end
end
