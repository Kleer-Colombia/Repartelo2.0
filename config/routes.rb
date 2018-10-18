# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
# frozen_string_literal: true
Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'landing#index'

  namespace :api do
    namespace :v1 do

      post '/login', to: 'auths#login'

      get '/saldos/:kleerer_id', to: 'saldos#find_saldos'
      post '/saldos/', to: 'saldos#add_saldo'

      get '/kleerers/', to: 'kleerers#find_all'
      get '/kleerers/filter', to: 'kleerers#find_without_co'

      get '/balance/', to: 'balance#find_all'
      post '/balance/', to: 'balance#distribute'
      post '/balance/close', to: 'balance#close'
      post '/balance/new', to: 'balance#create'
      get '/balance/:id', to: 'balance#find'
      delete '/balance/:id', to: 'balance#delete'
      post '/balance/:id/income', to: 'balance#add_income'
      delete '/balance/:id/income/:idIncome', to: 'balance#delete_income'
      post '/balance/:id/expense', to: 'balance#add_expense'
      delete '/balance/:id/expense/:idExpense', to: 'balance#delete_expense'
      post '/balance/:id/percentages', to: 'balance#update_percentages'

      post '/balance/:id/coachingSessions/new', to: 'coaching_sessions#create'
      get '/balance/:id/coachingSessions/', to: 'coaching_sessions#find'
      delete '/balance/:id/coachingSessions/:csId', to: 'coaching_sessions#delete'
      get '/balance/:id/coachingSessions/summary', to: 'coaching_sessions#summary'

    end
  end
end
