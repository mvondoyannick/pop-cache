class Api::V1::ApiController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:payment]
    #permet verifier un utilisateur
    def verif_user
        phone = params[:phone]

        #on recherche cet utilisateur
        user = Customer.where(phone: phone).first

        if user
            render json: user.as_json(only: [:name, :second_name]), status: :found
        else
            render json: {
                status: :not_found,
                message: 'unknow user'
            }
        end
    end


    #permet de verifier si le payeur dispose d'argent dans son compte
    def have_money
        
    end

    #permet de declencher le paiement
    def payment
        from = params[:payeur]
        to = params[:receveur]
        amount = params[:montant]
        pwd = params[:password]

        if !from.nil? && !pwd.nil?
            #--------------------------------------------------
            #creation du journale de transaction
            Journal::create_logs_transaction(from, to, amount)

            transaction = Client::pay(from, to, amount, pwd)
            render json: transaction
        else
            render json: {
                message: "failed",
                description: "Aucuns parametres recu"
            }
        end


        
    end
    
end