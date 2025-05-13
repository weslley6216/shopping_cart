require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :products
  resource :cart, only: %i[create show] do
    post 'add_item', on: :collection
    delete ':product_id', to: 'carts#remove_item', as: :remove_item
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'rails/health#show'
end
