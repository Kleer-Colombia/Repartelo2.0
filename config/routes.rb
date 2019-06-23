# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
# frozen_string_literal: true
Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'landing#index'

  namespace :api do
    namespace :v1 do

      post '/login', to: 'auths#login'

      get '/invoice/', to: 'alegra#find_open_invoices'
      get '/featureflags/', to: 'feature_flag#find_feature_flags'

      get '/saldos/:kleerer_id', to: 'saldos#find_saldos'
      post '/saldos/', to: 'saldos#add_saldo'

      get '/kleerers/', to: 'kleerers#find_all'
      get '/kleerers/filter', to: 'kleerers#find_without_co'

      post '/balance/new', to: 'balance#create'
      get '/balance/', to: 'balance#find_all'
      get '/balance/:id', to: 'balance#find'
      delete '/balance/:id', to: 'balance#delete'

      post '/balance/', to: 'balance_operations#distribute'
      post '/balance/close', to: 'balance_operations#close'
      post '/balance/taxes', to: 'balance_operations#calculate_taxes'
      post '/balance/:id/income', to: 'balance_operations#add_income'
      delete '/balance/:id/income/:idIncome', to: 'balance_operations#delete_income'
      post '/balance/:id/expense', to: 'balance_operations#add_expense'
      delete '/balance/:id/expense/:idExpense', to: 'balance_operations#delete_expense'
      post '/balance/:id/percentages', to: 'balance_operations#update_percentages'

      post '/balance/:id/coachingSessions/new', to: 'coaching_sessions#create'
      get '/balance/:id/coachingSessions/', to: 'coaching_sessions#find'
      delete '/balance/:id/coachingSessions/:csId', to: 'coaching_sessions#delete'
      post '/balance/:id/coachingSessions/summary', to: 'coaching_sessions#summary'

      get '/taxes/', to: 'taxes#resume_taxes'
      get '/taxes/:tax_id', to: 'taxes#resume_one_tax'
      post '/taxes/', to: 'taxes#add_tax'

    end
  end
end
