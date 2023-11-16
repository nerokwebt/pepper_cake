puts "Generating meals in database..."

File.readlines('./recipes-fr.json').each do |line|
  meal_attributes = JSON.parse(line)

  meal_attributes.except!('author_tip', 'budget')
  meal_name = Meal.create(meal_attributes).name
  puts "Created meal #{meal_name}"
end

puts "Meals generated!"
