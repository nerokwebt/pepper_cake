# frozen_string_literal: true

# This class normalizes data extracted from the recipes file, mainly to create ingredients in database used to match the user's search, by
# removing useless information for the search as weight or authors commentaries, helping to get a clean autocomplete. Though, the methods don't
# drop those weights and commentaries and store it in a column instead for display purposes.
class Normalizer
  TERMS_LIST = [
    'aiguillette',
    'aile',
    'barre',
    'barquette',
    'b[âa]ton',
    'blanc',
    'bloc',
    'boc(al|aux)',
    'bol',
    'bo[iî]tes? ?(.*)',
    'botte',
    'boule',
    'bouquet',
    'bouteille',
    'branche',
    'branchette',
    'brin',
    'brique',
    'briquette',
    'b[ûu]che',
    'carr[ée]',
    'centim[eè]tre',
    'cerneau',
    'chair',
    'coeur',
    'c[ôo]te',
    'c[ôo]telette',
    'couteau',
    'cube',
    'cuisse',
    'cuill[èe]res? ?(à|a|de)? ?(caf[ée]|soupe)? ?(.*)',
    'demi',
    'dé',
    'dose',
    'dosette',
    '[ée]paule',
    'extrait',
    'feuille',
    'filet',
    'foie',
    'grain',
    'gousse',
    'goutte',
    'jarret',
    'lamelle',
    'louche',
    'magret',
    'moitié',
    'morceaux?',
    'paquet',
    'pavé',
    'petite?',
    'pinc[ée]e',
    'plaque',
    'poign[ée]e',
    'pointe',
    'poitrine ?(fum[ée])?',
    'portion',
    'pot',
    'quartier',
    'queue',
    'r[âa]ble',
    'reste',
    'rondelle',
    'r[ôo]ti',
    'rouleaux?',
    'sac',
    'sachet',
    'saut[ée]',
    'tablette',
    'tasses? ?(à|a|de)? ?(caf[ée])? ?(.*)',
    'touffe',
    'trait',
    'tranches? ?([ée]paisses?|fines?)?',
    'tube',
    'verre',
    'zeste'
  ].join('|').freeze

  MATCH_TERMS = /(\d*)? ?(be(au|lle)s?|bon(ne)?s?|fine?s?|gros(se)?s?|grande?s?|petite?s?)? ?(#{TERMS_LIST})s? d['e]s?/

  MATCH_BEFORE = [
    /demi /,
    %r{\d+[\/\.]?(\d+)? ?([mk]?g|[mcd]?l) d['e]},
    /\A ?([mk]?g|[mcd]?l) d['e]/,
    %r{\d+[/\.]\d+},
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
    / d('|e )environ (.*)/,
    / d[ée]j[àa] (.*)/,
    / dans(.*)/,
    / finement(.*)/,
    / non (.*)/,
    / par personne(.*)/,
    /petite?s? /,
    / portions?(.*)/,
    / pour (.*)/,
    / soit (.*)/,
    / \S+®(.*)/,
    /(à|a|selon) ?(votre)? (convenance|volonté)(.*)/,
    / selon (.*)/,
    /[de ]?\d+ ?([mk]?g|[mcd]?l)? [aà]? \d+ ?([mk]?g|[mcd]?l)(.*)/,
    /[de ]?\d+ ?([mk]?g|[mcd]?l)(.*)/,
    /(a|à) ?\d+% ?(de)?(.*)/
  ].freeze

  MATCH_AFTER = [
    /\A(l'|l[ae] )/,
    / (d['e])? ?\d+(.*)\z/,
    /n°(.*)/, / n\z/
  ].freeze

  MATCH_LAST = [
    / d['e]? ?\z/,
    /\Ad('|e )/,
    / .\z/
  ].freeze

  TO_EXCLUDE = [
    /\Aeau(\z| (.*))/,
    /\Aficelle(.*)/,
    /\Ahuile(\z| (.*))/,
    /\Amélange(\z| (.*))/,
    /(\A|(.*) )poivre(\z| (.*))/,
    /(\A|(.*) )(gros)? ?sel(\z| (.*))/,
    /\Avinaigre(\z| (.*))/
  ].freeze

  COMPLEX_INGREDIENTS_TO_KEEP = %w[
    fécule
    pomme
    pommes
    vin
  ].freeze

  PLURAL_INGREDIENTS_TO_KEEP = %w[
    p[âa]tes
  ].freeze

  # Reads the json file to populate database
  def self.parse(file)
    lines_nb = File.foreach(file).count
    lines_count = 1

    File.readlines(file).each_with_index do |line, i|
      puts "\rParsing progess: #{i + 1} / #{lines_nb}"

      Normalizer.normalize_and_populate_db(JSON.parse(line))
    end

    Normalizer.clean_db
    puts 'All meals and ingredients generated!'
  end

  # Normalizes meals and ingredients and creates records in database
  def self.normalize_and_populate_db(meal_attributes)
    # Can't use meals without an image in app
    return if meal_attributes['image'].blank?

    # Removes the attributes we are not using in the app
    meal_attributes.except!('author_tip', 'budget', 'prep_time', 'cook_time')

    # Renames column so we can differentiate Ingredients association for ingredients stored in Meal column in database
    meal_attributes['display_ingredients'] = meal_attributes.delete('ingredients').uniq

    ingredients_meals_attributes = Normalizer.normalize_and_create_ingredients(meal_attributes['display_ingredients'])

    return unless ingredients_meals_attributes.any?

    # Passes ingredients_meals_attributes through accepts_nested_attributes in meal.rb
    meal_attributes[:ingredients_meals_attributes] = ingredients_meals_attributes.uniq
    Normalizer.normalize_and_create_meals(meal_attributes)
  end

  # Removes useless ingredients after normalizing
  def self.clean_db
    # Ordering is mandatory for both complex and plural ingredients deletion
    ingredients = Ingredient.order(:name)

    complex_ingredients_ids_to_delete = Normalizer.select_duplicated_complex_ingredients_ids(ingredients)

    puts 'Deleting complex ingredients...'
    Ingredient.where(id: complex_ingredients_ids_to_delete).destroy_all
    puts 'Deleted complex ingredients!'

    plural_ingredients_ids_to_delete = Normalizer.select_duplicated_plural_ingredients_ids(ingredients)
    puts 'Deleting plural ingredients...'
    Ingredient.where(id: plural_ingredients_ids_to_delete).destroy_all
    puts 'Deleted plural ingredients!'
  end

  def self.normalize_and_create_meals(meal_attributes)
    meal_attributes['name'] = meal_attributes['name'].capitalize

    Normalizer.create_in_db(meal_attributes, Meal)
  end

  # Normalizes ingredients by removing weight and/or useless information for the database
  def self.normalize_and_create_ingredients(ingredients)
    ingredients.filter_map do |ingredient|
      ingredient_attributes = Normalizer.match_ingredient(ingredient)

      created_ingredient = Normalizer.create_in_db(ingredient_attributes, Ingredient) if ingredient_attributes[:name].present?

      created_ingredient ? { ingredient_id: created_ingredient.id || Ingredient.where(name: created_ingredient.name).first.id } : nil
    end
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
    ingredient = ingredient.gsub(/#{MATCH_TERMS}/, '')
    ingredient = ingredient.gsub(Regexp.union(MATCH_AFTER), '')
    ingredient = ingredient.gsub(Regexp.union(MATCH_LAST), '')

    # Replaces all multiple spaces at once by only one space
    ingredient = ingredient.gsub(/\s+/, ' ')
    ingredient = ingredient.strip

    # Excludes unnecessary ingredients in search
    ingredient = ingredient.gsub(Regexp.union(TO_EXCLUDE), '')
    ingredient = ingredient.strip

    { name: ingredient }
  end

  # Creates the object in database
  def self.create_in_db(attributes, object_class)
    object_class.create(attributes)
  end

  # Removes too complex ingredients for users that have a simpler duplicate
  def self.select_duplicated_complex_ingredients_ids(ingredients)
    ingredients_ids_to_delete = []
    ingredients.each do |ingredient|
      ingredient_name = ingredient.name
      split_ingredient_name = ingredient_name.split

      # Do not remove complex version of specified ingredients
      next if split_ingredient_name[0].in?(COMPLEX_INGREDIENTS_TO_KEEP)

      simple_ingredient_to_keep = Ingredient.where('name LIKE ?', split_ingredient_name[0].to_s).first

      # Do not remove ingredient when it has no simpler version
      next unless (split_ingredient_name.size > 1) && simple_ingredient_to_keep

      ingredients_ids_to_delete << ingredient.id

      # Replaces the ingredient to delete with its simple version
      ingredient.meals.each do |meal|
        IngredientsMeal.where(ingredient: simple_ingredient_to_keep, meal: meal).first_or_create
      end

      puts "Preparing to delete complex ingredient #{ingredient_name}..."
    end

    ingredients_ids_to_delete
  end

  # Removes duplicates ingredients that have a plural if the singular already exists
  def self.select_duplicated_plural_ingredients_ids(ingredients)
    ingredients_ids_to_delete = []
    ingredients.each do |ingredient|
      ingredient_name = ingredient.name
      split_ingredient_name = ingredient_name.split

      # Do not remove plural version of specified ingredients
      next if split_ingredient_name[0].in?(PLURAL_INGREDIENTS_TO_KEEP)

      singularized_name = split_ingredient_name[0].singularize
      singular_ingredient_to_keep = Ingredient.where(name: singularized_name).where.not(id: ingredient.id).first

      # Do not remove the ingredient when it has no singular version
      next unless singular_ingredient_to_keep && (split_ingredient_name[0] != singularized_name)

      ingredients_ids_to_delete << ingredient.id

      # Replaces the ingredient to delete with its singular version
      ingredient.meals.each do |meal|
        IngredientsMeal.where(ingredient: singular_ingredient_to_keep, meal: meal).first_or_create
      end

      puts "Preparing to delete duplicated plural ingredient #{ingredient_name}..."
    end

    ingredients_ids_to_delete
  end
end
