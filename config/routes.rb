Rails.application.routes.draw do
  # managing action cable
  mount ActionCable.server => "/cable"
  get 'welcome/home'
  get 'p/parameters/accounts', to: 'welcome#accounts'
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

  #authentification des utilisateurs pmq

  get 'auth/log_in', to: "welcome#login"
  post 'home', to: "welcome#auth"
  get 'dashboard', to: "welcome#home" 
  namespace :dashboard do
    namespace :users do
      get "credit", to: "welcome#credit"
    end
  end

  resources :roles

  #gestion des agents partenaire de la plateforme
  scope :agentcrtl do
    get "activity/:customer_id", to: "agentcrtl#customer_activity"        #retourne toutes les activités d'un customer
    get "qrcode/:customer_id", to: "agentcrtl#create_qrcode"              #permet de creer le QRcode pour un customer defini
    match 'debit_customer_account', to: 'agentcrtl#debit_customer_account', via: [:get, :post]
    match 'activate_customer_account', to: 'agentcrtl#activate_customer_account', via: [:get, :post]
    get 'create_qrcode/:customer_token', to: 'agentcrtl#intend_qrcode'
  end


  get 'agentcrtl/signin'
  post 'agentcrtl/attemp_signin'
  get 'agentcrtl/index'
  get 'agentcrtl/customer'                                                        #affiche tous les customer
  get 'agentcrtl/new'
  get 'agentcrtl/new_customer'
  post 'agentcrtl/intent_new_customer'
  get 'agentcrtl/credit_customer'
  post 'agentcrtl/intent_credit_customer'
  post 'agentcrtl/intent_debit_customer'
  #post 'agentcrtl/activate_customer_account'
  get 'agentcrtl/search_phone'
  get 'agentcrtl/create_qrcode'                                                   #permet de generer un qrcode
  get 'agentcrtl/edit'
  get 'agentcrtl/delete'
  get 'agentcrtl/new_qrcode'
  get 'agentcrtl/journal'
  get 'agentcrtl/activate_customer'
  post 'agentcrtl/activate_customer'

  # blocage et debloquage d'un compte utilisateur
  # blocage
  scope :customer do
    get 'search/lock', to: 'agentcrtl#lock_customer_account'
    post 's/query', to: 'agentcrtl#search'
    get 's/response', to: 'agentcrtl#result'
    get 'u/response', to: 'agentcrtl#result_unlock'          #pour le resultalt de deblocage
    match 's', to: 'agentcrtl#lock_customer_account', via: [:post]
    match 'validate/lock', to: 'agentcrtl#validate_lock_customer_account', via: [:get]
    match 'search_unlock_customer_account', to: 'agentcrtl#search_unlock_customer_account', via: [:get, :post]
  end

  #deblocage
  get 'agentcrtl/unlock_customer_account'

  # fin
  resources :cats
  resources :categories
  resources :categorie_services
  resources :types
  resources :services

  devise_for :partners
  # devise_for :agents, controllers: {
  #   sessions: 'agents/sessions'
  # }
  devise_for :customers, controllers: { 
    sessions: 'customer/sessions'
  }
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

  #######################################
  ##                                   ##
  ##            ROOT ROUTE             ##
  ##                                   ##
  #######################################
  root to: 'welcome#home'

  #######################################
  ##                                   ##
  ##          WEBVIEW SCOPE            ##
  ##                                   ##
  #######################################
  # Webview for mobile devise
  scope '/transactions/' do
    get 'transaction/:hash/:token', to: "welcome#webview"
     
    # navigating account on webview PMQ lite
    get 'accounts/:token/login', to: "welcome#login"

    # creating new account
    get 'transactions/accounts', to: "welcome#webview"

    # make a payment
    get 'payments/pay', to: "welcome#webview"

    # scan qrcode for payment
    get 'payments/pay/scan', to: "welcome#webview"
  end
  get 'webview/:hash/:token', to: 'welcome#webview'
  namespace :webview do
    namespace :payment do
      get 'pay', to: 'webview#pay'
      get 'scan', to: 'webview#scan'
      get 'code', to: 'webview#code'
      get 'phone', to: 'webview#phone'
      get 'sms', to: 'webview#sms'
      get 'email', to: 'webview#email'
    end
    namespace :auth do
      get 'login', to: 'webview#login'
      get 'signup', to: 'webview#signup'
    end
  end

  #######################################
  ##                                   ##
  ##        ADMIN | PARTNER SCOPE      ##
  ##                                   ##
  #######################################
  scope :admin do
    scope :users do
      get 'show', to: "welcome#users"
      get 'validate', to: "welcome#validate_account"
      get 'invalid_account', to: "welcome#invalidate_account"
      get 'accounts_journal', to: "welcome#accounts_journal"
      get 'user/:token', to: "welcome#user"
      get 'recharge', to: "welcome#recharge"
      post 'recharge', to: "welcome#recharge"
      get 'retrait', to: "welcome#retrait"
      post 'retrait', to: "welcome#retrait"
    end

    scope :bank do
      get 'compensation', to: "welcome#compensation"
    end

    # roles administrations
    scope :roles do
      get 'show', to: "welcome#roles"
      get 'add', to: "welcome#roles_add"
      post 'add', to: "welcome#roles_add"
    end
  end

  scope :home do
    match 'retrait', to: 'home#retrait', via: [:get, :post]
    match 'create', to: 'home#create', via: [:get, :post]
    match 'credit', to: 'home#credit', via: [:get, :post]
    get 'account/particulier', to: 'home#particulier'
  end

  get 'home/compte'

  #concernant les agent
  resources :agents
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  #API main root
  namespace :api, defaults: {format: :json} do

    #Main routing to the plateform PayMeQuick
    namespace :v1 do

      scope :session do
        match "signin", to: "session#signin", via: [:post, :options]                # login to account
        match "signup", to: "session#signup", via: [:post, :options]                # create account
        match "get_balance", to: "session#getSoldeCustomer", via: [:post, :options] # get user balance

        # Transaction or payment
        match 'transaction/:token/:receveur/:montant/:password/:oneSignalID', to: 'api#payment', via: [:post, :options]
        post 'transaction/payment', to: 'api#payment'                 #New payment including post request updated
        match 'qrcode', to: 'api#qrcode', via: [:options, :post]
        match 'code', to: 'api#code', via: [:options, :post]     #rechercher via le code numerique
        match 'history/:phone', to: 'api#user_history', via: [:get, :options]

        match 'check_retrait', to: 'session#check_retrait', via: [:post, :options]
        match 'cancel_retrait', to: 'session#cancel_retrait', via: [:post, :options]
        match 'validate_retrait', to: 'session#validate_retrait', via: [:post, :options]
        match 'validate/authentication', to: 'session#signup_authentication', via: [:post, :options]
        match 'history', to: 'session#history', via: [:post, :options]
        match 'history/detail/:code', to: 'session#histoDetail', via: [:get, :options]
      end
      ##authentification et creation de compte
      #match 'session/signin', to: 'session#signin', via: [:post, :options]
      #match 'session/signup', to: 'session#signup', via: [:post, :options]
      #
      ## get user balance
      #match 'session/get_balance', to: 'session#getSoldeCustomer', via: [:post, :options]                #retourne le solde du client

      ## Transaction or payment
      #match 'session/transaction/:token/:receveur/:montant/:password/:oneSignalID', to: 'api#payment', via: [:post, :options]
      #post 'session/transaction/payment', to: 'api#payment'                 #New payment including post request updated
      #match 'session/qrcode', to: 'api#qrcode', via: [:options, :post]
      #match 'session/code', to: 'api#code', via: [:options, :post]     #rechercher via le code numerique
      #match 'session/history/:phone', to: 'api#user_history', via: [:get, :options]
      #
      #match 'session/check_retrait', to: 'session#check_retrait', via: [:post, :options]
      #match 'session/cancel_retrait', to: 'session#cancel_retrait', via: [:post, :options]
      #match 'session/validate_retrait', to: 'session#validate_retrait', via: [:post, :options]
      #match 'session/validate/authentication', to: 'session#signup_authentication', via: [:post, :options]
      #match 'session/history', to: 'session#history', via: [:post, :options]
      #match 'session/history/detail/:code', to: 'session#histoDetail', via: [:get, :options]

      match 'test/:code(/:amount)', to: 'api#test', via: [:get, :options]
      match 'session/service', to: 'session#service', via: [:post, :options]
      match 'security/question/', to: 'session#question', via: [:get, :options]
      match 'security/retrive/password', to: 'session#retrivePassword', via: [:post, :options]
      match 'security/reset/password', to: 'session#resetPassword', via: [:post, :options]
      match 'session/phone', to: 'session#getPhoneNumber', via: [:post, :options]
      post 'security/fingerprint/validate', to: "session#fingerprint"

      # Web Test
      post 'web/check', to: 'session#checkToken'

      # Gestion des UUID
      post 'session/uuid', to: 'session#authNewUuidDevice'

      # Afficher dynamiquement le solde du client, comme un evenement
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
      post 'recharge/extern/provider/virtual/sp', to: 'session#virtualSP'
      
      # configuration du compte personnel

      match 'security/authorization', to: 'session#authorization', via: [:post, :options]
      match 'security/authorization/update/account', to: 'session#updateAccount', via: [:post, :options]
      match 'security/authorization/update/password', to: 'session#updatePassword', via: [:post, :options]
      
      # Paiement via la plateforme USSD

      match 'payment/extern/ussd/:data', to: 'api#paymentUssdExt', via: [:get, :options]

      #gestion des agents et de leur comptes

      get 'agents/signin/:email/:password', to: 'agent#signin'
      post 'agents/signin', to: 'agent#signin'
      match 'search/code/:code', to: 'agent#searchQrcodeByCode', via: [:get, :options]
      match 'search/scan/:data', to: 'agent#searchQrCodeByScan', via: [:get, :options]
      match 'update/:token/:phone/:cni/:name/:second_name/:sexe/:authenticated', to: 'agent#update', via: [:get, :options]
      match 'search/phone/:phone', to: 'agent#searchCustomerByPhone', via: [:get, :options]
      match 'links/link/:token/:qrcode', to: 'agent#link', via: [:get, :options]

      #gestion des utilisateurs sur le desktop
      get 'client/logs/:token', to: 'customer#history'

      # gestion des SOS payment
      scope :sos do
        post "request", to: "session#generate_sos"
        post 'list', to: "session#list_sos"
        post 'detail', to: "session#details_sos"
      end

      #terminer les interface clientes
      scope :customer do

        scope :partner do
          post 'signin', to: 'agent#signin'
          post 'customer/new', to: 'agent#new_customer'
          post 'customer/credit', to: 'agent#credit_customer'
          post 'debit', to: 'agent#debit_customer'
          post 'activer/search', to: 'agent#search_customer'
          post 'activate/validate', to: 'agent#activate_customer'
          get 'journal', to: 'agent#journal'

        end

        scope :otp do

          scope :signin do
            post '/', to: 'customer#signin'
            post 'validate', to: 'customer#validate_signin'
          end

          scope :signup do
            post '/', to: 'customer#signup'
            post 'validate', to: 'customer#validate_signup'
          end
        end
      end

      #paiement sans compte sur la plateforme, simplement avec un numero de telephone
      post 'external/request/intent', to: 'api#phonePayment'

      # routes for mrechargement
      post 'mrecharge/all', to: 'session#mrecharge'

    end
  end
end
