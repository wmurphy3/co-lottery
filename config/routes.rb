Rails.application.routes.draw do
  mount Lockup::Engine, at: '/lockup'

  resources :dashboard, only: [:index]

  root to: 'dashboard#index'
end
