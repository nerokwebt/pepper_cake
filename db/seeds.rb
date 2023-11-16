puts "Generating meals in database..."

File.readlines('./recipes-fr.json').each do |line|
  json = JSON.parse(line)

  json.except!('author_tip', 'budget')
  meal = Meal.create(json)
  puts "Created #{meal.name}"
end

puts "Meals generated!"