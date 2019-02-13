Rails.application.routes.draw do
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
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  #API main root
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      match 'session/signin', to: 'session#signin', via: [:post, :options]
      match 'session/signup', to: 'session#signup', via: [:post, :options]
      match 'session/get_balance/:phone/:password', to: 'session#get_balance', via: [:get, :options]
      match 'session/transaction', to: 'api#payment', via: [:post, :options]
    end
  end
end
