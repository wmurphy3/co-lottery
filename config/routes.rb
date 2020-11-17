Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :games, only: [:index, :show] do
    collection do
      get :get_next
    end
    member do
      get :entered
      get :steal
    end
  end
  resources :how_to, only:[:index]
  resources :dashboard, only: [:index]
  resources :users, only: [:create]
  resources :user_prizes, only: [:create]

  root to: 'dashboard#index'
end
