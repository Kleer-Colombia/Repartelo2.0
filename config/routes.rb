# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
# frozen_string_literal: true
Rails.application.routes.draw do

  root to: 'landing#index'

  namespace :api do
    namespace :v1 do

      get '/saldos/:kleerer_id', to: 'saldos#find_saldos'
      post '/saldos/', to: 'saldos#add_saldo'

      resources :kleerers do
        resources :books
      end

      post '/login', to: 'auths#login'
    end
  end
end
