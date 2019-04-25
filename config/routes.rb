Rails.application.routes.draw do
  get 'parametres/index'
  get 'parametres/rapprochement'
  get 'parametres/agence'
  get 'parametres/utilisateur'
  get 'parametres/journal'

  # creation d'un scope
  resources :parametres do

  end
  # fin
  resources :roles
  get 'agentcrtl/index'
  get 'agentcrtl/customer'                                                        #affiche tous les customer
  get "agentcrtl/activity/:customer_id", to: "agentcrtl#customer_activity"        #retourne toutes les activités d'un customer
  get "agentcrtl/qrcode/:customer_id", to: "agentcrtl#create_qrcode"              #permet de creer le QRcode pour un customer defini
  get 'agentcrtl/new'
  get 'agentcrtl/new_customer'
  post 'agentcrtl/intent_new_customer'
  get 'agentcrtl/credit_customer'
  post 'agentcrtl/intent_credit_customer'
  get 'agentcrtl/debit_customer_account'
  post 'agentcrtl/intent_debit_customer'
  get 'agentcrtl/create_qrcode'                                                   #permet de generer un qrcode
  get 'agentcrtl/create_qrcode/:customer_token', to: 'agentcrtl#intend_qrcode'
  get 'agentcrtl/edit'
  get 'agentcrtl/delete'
  get 'agentcrtl/new_qrcode'
  get 'agentcrtl/journal'
  resources :cats
  resources :categories
  resources :categorie_services
  resources :types
  resources :services

  devise_for :partners
  devise_for :agents, controllers: {
    sessions: 'agents/sessions'
  }
  #devise_for :customers
  get 'verify/query'
  get 'verify/verify'
  resources :accounts
  resources :users
  get 'home/index'
  get 'home/public'
  get 'home/private'
  get 'home/login'
  get 'home/apikey'
  post 'home/apikey_request'
  get 'home/signup'
  #main route
  root 'agentcrtl#customer'
  match 'home/retrait', to: 'home#retrait', via: [:get, :post]
  match 'home/create', to: 'home#create', via: [:get, :post]
  match 'home/credit', to: 'home#credit', via: [:get, :post]
  get 'home/compte'
  get 'home/account/particulier', to: 'home#particulier'
  #concernant les agent
  resources :agents
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  #API main root
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      match 'session/signin', to: 'session#signin', via: [:post, :options, :get]
      match 'session/signup', to: 'session#signup', via: [:post, :options]
      match 'session/get_balance/:customer/:password', to: 'session#getSoldeCustomer', via: [:get, :options]
      match 'session/transaction/:token/:receveur/:montant/:password', to: 'api#payment', via: [:get, :options]
      match 'session/qrcode/:data', to: 'api#qrcode', via: [:options, :get]
      match 'session/history/:phone', to: 'api#user_history', via: [:get, :options] 
      match 'session/balance/:phone/:password', to: 'session#solde', via: [:get, :options]
      match 'session/check_retrait', to: 'session#check_retrait', via: [:post, :options]
      match 'session/cancel_retrait', to: 'session#cancel_retrait', via: [:post, :options]
      match 'session/validate_retrait/:token/:password', to: 'session#validate_retrait', via: [:get, :options]
      match 'session/validate/authentication', to: 'session#signup_authentication', via: [:post, :options]
      match 'session/history', to: 'session#histo', via: [:post, :options]
      match 'session/history/detail/:code', to: 'session#histoDetail', via: [:get, :options]
      #match 'session/history/h/payment', to: 'session#p', via: [:post, :options]
      match 'test/:code(/:amount)', to: 'api#test', via: [:get, :options]
      match 'session/service', to: 'session#service', via: [:post, :options]
      match 'session/categories', to: 'session#serviceCategorie', via: [:get, :options]
      match 'session/categorie/:id', to: 'session#detailCategorie', via: [:post, :options]
      match 'test/:phone', to: 'api#test', via: [:get, :options]
      match 'security/question/', to: 'session#question', via: [:get, :options]
      match 'security/retrive/password', to: 'session#retrivePassword', via: [:post, :options]
      match 'security/reset/password', to: 'session#resetPassword', via: [:post, :options]
      match 'session/phone', to: 'session#getPhoneNumber', via: [:post, :options]

      # integration de sprintPay Solution API

      match 'recharge/extern/provider/sp/new/:token/:phone/:amount', to: 'session#getSpData', via: [:get, :options]
      match 'recharge/extern/provider/sp/:token/:phone/:amount/:network_name', to: 'session#rechargeSprintPay', via: [:get, :options]   # SprintPay OM et MOMO

      # configuration du compte personnel

      match 'security/authorization/:token/:password', to: 'session#authorization', via: [:get, :options]
      match 'security/authorization/update/account/:token/:name/:second_name/:sexe(/:password)', to: 'session#updateAccount', via: [:get, :options]
      
      # Paiement via la plateforme USSD

      match 'payment/extern/ussd/:data', to: 'api#paymentUssdExt', via: [:get, :options]

      #gestion des agents

      match 'agents/sigin/:phone/:password', to: 'agent#signin', via: [:get, :options]
      match 'search/code/:code', to: 'agent#searchQrcodeByCode', via: [:get, :options]
      match 'search/scan/:data', to: 'agent#searchQrCodeByScan', via: [:get, :options]
      match 'update/:token/:phone/:cni/:name/:second_name/:sexe/:authenticated', to: 'agent#update', via: [:get, :options]
      match 'search/phone/:phone', to: 'agent#searchCustomerByPhone', via: [:get, :options]
      match 'links/link/:token/:qrcode', to: 'agent#link', via: [:get, :options]
    end
  end
end
