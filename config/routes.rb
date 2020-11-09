Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :games, only: [:index, :show]
  resources :how_to, only:[:index]
  resources :dashboard, only: [:index]

  root to: 'dashboard#index'
end
