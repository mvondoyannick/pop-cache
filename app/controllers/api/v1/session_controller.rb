class Api::V1::SessionController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:signup, :signin]
    #pour la connexion de l'utilisateur
    def create

    end

    #creation de compte utilisateur
    def signup
        email = "me@me.com"
        query = Client::create_user(params[:nom], params[:prenom], params[:phone], params[:cni], params[:password])
        render json: {
            #message: :in_progress,
            status: query
        }

        #processus de creation des comptes utilisateurs
    end


    def get_balance
        phone = params[:phone]
        password = params[:password]
        balance = Client::get_balance(phone, password)
        render json: balance
    end

    

    def signin
        phone = params[:phone]
        password = params[:password]

        #query the user
        signin = Client::auth_user(phone, password)
        render json: signin
    end

    #pour la deconnexion de l'utilisateur
    def descroy
    end

    def transaction
        from = params[:payeur]
        to = params[:receveur]
        amount = params[:montant]
        password = params[:password]

        transaction = Client::transaction(from, to, amount, password)
        render json: transaction
    end

    private

    def account_params
        params.require(:customer).permit(:name, :second_name, :cni, :phone)
    end

end