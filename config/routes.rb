Rails.application.routes.draw do

  get '/api/v1/items/find', to: 'api/v1/items#find'

  get '/api/v1/merchants/find_all', to: 'api/v1/merchants#find_all'


  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show] do
        resources :items, only: :index, controller: :merchant_items
      end
      resources :items do
        resources :merchant, controller: :item_merchant, method: :index
      end
    end
  end
end
