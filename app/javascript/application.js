// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails"
import "controllers"

const choices = new Choices('.ingredient-select');
console.log(choices)