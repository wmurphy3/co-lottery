Rails.application.routes.draw do
  mount Lockup::Engine, at: '/lockup'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :admin do
    resources :dashboard do
      collection do 
        get :cache
        get :report
      end
    end
  end
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
  resource :upgrade, only: [:show]

  root to: 'dashboard#index'
end
