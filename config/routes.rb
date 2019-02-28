Rails.application.routes.draw do
  devise_for :agents
  #devise_for :customers
  get 'verify/query'
  get 'verify/verify'
  resources :accounts
  resources :users
  get 'home/index'
  get 'home/public'
  get 'home/private'
  get 'home/login'
  get 'home/signup'
  #main route
  root 'home#index'
  match 'home/retrait', to: 'home#retrait', via: [:get, :post]
  match 'home/create', to: 'home#create', via: [:get, :post]
  match 'home/credit', to: 'home#credit', via: [:get, :post]
  get 'home/compte'
  get 'home/account/particulier', to: 'home#particulier'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  #API main root
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      match 'session/signin', to: 'session#signin', via: [:post, :options]
      match 'session/signup', to: 'session#signup', via: [:post, :options]
      match 'session/get_balance/:phone/:password', to: 'session#get_balance', via: [:get, :options]
      match 'session/transaction', to: 'api#payment', via: [:post, :options]
      match 'session/qrcode/:data', to: 'api#qrcode', via: [:get, :options]
      match 'session/history/:phone', to: 'api#user_history', via: [:get, :options] 
      match 'session/balance/:phone/:password', to: 'session#solde', via: [:get, :options]
      match 'session/check_retrait/:phone', to: 'session#check_retrait', via: [:get, :options]
      match 'session/validate_retrait', to: 'session#validate_retrait', via: [:post, :options]
    end
  end
end
