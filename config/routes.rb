Rails.application.routes.draw do
  root to: 'home#index'

  resources :meals, only: [:index, :show]
end
