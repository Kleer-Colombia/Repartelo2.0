# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
# frozen_string_literal: true
Rails.application.routes.draw do

  root to: 'landing#index'

  namespace :api do
    namespace :v1 do
      resources :kleerers do
        resources :books
      end

      resource :auth, only: %i[create]
    end
  end
end
