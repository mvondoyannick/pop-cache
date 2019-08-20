Rails.application.routes.draw do
  get 'welcome/home'
  #gestion des interfaces des clients
  get 'client/signing'
  get 'client/signup'
  get 'client/parameters'
  get 'client/index'
  post 'client/attemp_login'
  post 'client/attemp_signup'

  #Gestion des parametres generaux
  get 'parametres/index'
  get 'parametres/rapprochement'
  get 'parametres/agence'
  get 'parametres/utilisateur'
  get 'parametres/journal'

  #gestion des partenaires
  #
  # fin de gestion des partenaires

  # creation d'un scope
  resources :parametres do

  end
  # fin
  resources :roles

  #gestion des agents partenaire de la plateforme
  get 'agentcrtl/signin'
  post 'agentcrtl/attemp_signin'
  get 'agentcrtl/index'
  get 'agentcrtl/customer'                                                        #affiche tous les customer
  get "agentcrtl/activity/:customer_id", to: "agentcrtl#customer_activity"        #retourne toutes les activités d'un customer
  get "agentcrtl/qrcode/:customer_id", to: "agentcrtl#create_qrcode"              #permet de creer le QRcode pour un customer defini
  get 'agentcrtl/new'
  get 'agentcrtl/new_customer'
  post 'agentcrtl/intent_new_customer'
  get 'agentcrtl/credit_customer'
  post 'agentcrtl/intent_credit_customer'
  match 'agentcrtl/debit_customer_account', to: 'agentcrtl#debit_customer_account', via: [:get, :post]
  post 'agentcrtl/intent_debit_customer'
  match 'agentcrtl/activate_customer_account', to: 'agentcrtl#activate_customer_account', via: [:get, :post]
  #post 'agentcrtl/activate_customer_account'
  get 'agentcrtl/search_phone'
  get 'agentcrtl/create_qrcode'                                                   #permet de generer un qrcode
  get 'agentcrtl/create_qrcode/:customer_token', to: 'agentcrtl#intend_qrcode'
  get 'agentcrtl/edit'
  get 'agentcrtl/delete'
  get 'agentcrtl/new_qrcode'
  get 'agentcrtl/journal'
  get 'agentcrtl/activate_customer'
  post 'agentcrtl/activate_customer'
  # blocage et debloquage d'un compte utilisateur
  # blocage
  get 'customer/search/lock', to: 'agentcrtl#lock_customer_account'
  post 'customer/s/query', to: 'agentcrtl#search'
  get 'customer/s/response', to: 'agentcrtl#result'
  get 'customer/u/response', to: 'agentcrtl#result_unlock'          #pour le resultalt de deblocage
  match 'customer/s', to: 'agentcrtl#lock_customer_account', via: [:post]
  match 'customer/validate/lock', to: 'agentcrtl#validate_lock_customer_account', via: [:get]

  #deblocage
  get 'agentcrtl/unlock_customer_account'
  match 'customer/search_unlock_customer_account', to: 'agentcrtl#search_unlock_customer_account', via: [:get, :post]
  # fin
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
  root 'welcome#home'
  get 'webview/:hash/:token', to: 'welcome#webview'
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

    #Main routing to the plateform PayMeQuick
    namespace :v1 do
      #authentification et creation de compte
      match 'session/signin', to: 'session#signin', via: [:post, :options]
      match 'session/signup', to: 'session#signup', via: [:post, :options]

      # get user balance
      match 'session/get_balance', to: 'session#getSoldeCustomer', via: [:post, :options]                #retourne le solde du client

      # Transaction or payment
      match 'session/transaction/:token/:receveur/:montant/:password/:oneSignalID', to: 'api#payment', via: [:post, :options]
      post 'session/transaction/payment', to: 'api#payment'                 #New payment including post request updated
      match 'session/qrcode', to: 'api#qrcode', via: [:options, :post]
      match 'session/code', to: 'api#code', via: [:options, :post]     #rechercher via le code numerique
      match 'session/history/:phone', to: 'api#user_history', via: [:get, :options] 
      # match 'session/balance/:phone/:password', to: 'session#solde', via: [:get, :options]
      match 'session/check_retrait', to: 'session#check_retrait', via: [:post, :options]
      match 'session/cancel_retrait', to: 'session#cancel_retrait', via: [:post, :options]
      match 'session/validate_retrait', to: 'session#validate_retrait', via: [:post, :options]
      match 'session/validate/authentication', to: 'session#signup_authentication', via: [:post, :options]
      match 'session/history', to: 'session#history', via: [:post, :options]
      match 'session/history/detail/:code', to: 'session#histoDetail', via: [:get, :options]
      #match 'session/history/h/payment', to: 'session#p', via: [:post, :options]
      match 'test/:code(/:amount)', to: 'api#test', via: [:get, :options]
      match 'session/service', to: 'session#service', via: [:post, :options]
      # match 'session/categories', to: 'session#serviceCategorie', via: [:get, :options]
      # match 'session/categorie/:id', to: 'session#detailCategorie', via: [:post, :options]
      # match 'test/:phone', to: 'api#test', via: [:get, :options]
      match 'security/question/', to: 'session#question', via: [:get, :options]
      match 'security/retrive/password', to: 'session#retrivePassword', via: [:post, :options]
      match 'security/reset/password', to: 'session#resetPassword', via: [:post, :options]
      match 'session/phone', to: 'session#getPhoneNumber', via: [:post, :options]

      # Web Test
      post 'web/check', to: 'session#checkToken'

      # Gestion des UUID
      post 'session/uuid', to: 'session#authNewUuidDevice'

      # Afficher dynamiquement le solde du client
      post 'session/solde/show', to: 'api#customer_account_amount'

      # historique des clients mobile
      get 'history/:period', to: 'session#history'
      post 'history', to: 'session#history'
      post 'histories/timemachine', to: 'session#historyByDate'

      # test de la connexion internet
      match 'internet/test', to: 'session#testNetwork', via: [:get, :options, :post]
      match 'security/check/phone', to: 'session#checkPhone', via: [:post, :options]

      # integration de sprintPay Solution API

      match 'recharge/extern/provider/sp/new', to: 'session#getSpData', via: [:post, :options]
      match 'recharge/extern/provider/sp', to: 'session#rechargeSprintPay', via: [:post, :options]   # SprintPay OM et MOMO

      # configuration du compte personnel

      match 'security/authorization', to: 'session#authorization', via: [:post, :options]
      match 'security/authorization/update/account', to: 'session#updateAccount', via: [:post, :options]
      match 'security/authorization/update/password', to: 'session#updatePassword', via: [:post, :options]
      
      # Paiement via la plateforme USSD

      match 'payment/extern/ussd/:data', to: 'api#paymentUssdExt', via: [:get, :options]

      #gestion des agents

      get 'agents/signin/:email/:password', to: 'agent#signin'
      post 'agents/signin', to: 'agent#signin'
      match 'search/code/:code', to: 'agent#searchQrcodeByCode', via: [:get, :options]
      match 'search/scan/:data', to: 'agent#searchQrCodeByScan', via: [:get, :options]
      match 'update/:token/:phone/:cni/:name/:second_name/:sexe/:authenticated', to: 'agent#update', via: [:get, :options]
      match 'search/phone/:phone', to: 'agent#searchCustomerByPhone', via: [:get, :options]
      match 'links/link/:token/:qrcode', to: 'agent#link', via: [:get, :options]

      #gestion des utilisateurs sur le desktop
      post 'customer/otp/signin', to:            'customer#signin'
      post 'customer/otp/signin/validate', to:   'customer#validate_signin'
      post 'customer/otp/signup', to:            'customer#signup'
      post 'customer/otp/signup/validate', to:   'customer#validate_signup'
      get 'client/logs/:token', to:                     'customer#history'

      #terminer les interface clientes
      post 'customer/patner/signin', to: 'agent#signin'
      post 'customer/patner/customer/new', to: 'agent#new_customer'
      post 'customer/patner/customer/credit', to: 'agent#credit_customer'
      post 'customer/patner/debit', to: 'agent#debit_customer'
      post 'customer/patner/activer/search', to: 'agent#search_customer'
      post 'customer/partner/activate/validate', to: 'agent#activate_customer'
      get 'customer/partner/journal', to: 'agent#journal'

      #paiement sans compte sur la plateforme, simplement avec un numero de telephone
      post 'external/request/intent', to: 'api#phonePayment'
    end
  end
end
