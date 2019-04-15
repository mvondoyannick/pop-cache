class Api::V1::ApiController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:payment, :qrcode, :test]

		#require 'rqrcode'

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

    def test
      #ApplicationController.renderer.defaults
			phone = params[:code]
			render json: {
					message: Customer.find_by_phone(phone).as_json(only: [:name, :second_name, :phone, :cni])
			}
		end

		def qrcode
			#data = Parametre::Crypto::decode(params[:data])
			data = Base64.decode64(params[:data]).split("#")

			#recheche du payeur
			payeur_global = data[0]

			#information du marchand
			marchand_global = data[1]

			#extraction des informations du payeur
			ex_payeur = payeur_global.split("@")

			query_p = Customer.find_by_authentication_token(ex_payeur[0])
			if query_p.blank?
				puts "Impossible de trouver cet utilisateur"
				render json: {
					message: "Impossible de trouver cet utilisateur"
				}
			else
				puts  "informations du marchand"
				ex_marchand = marchand_global.split("@")
				q = Customer.find_by_authentication_token(ex_marchand[0])
				if q.blank?
					render json: {
						message: "Impossible de trouver cet utilisateur!"
					}
				else
					render json:{
						message: true,
						context: ex_marchand[4],
						name: q.name,
						second_name: q.second_name,
						amount: ex_marchand[1],
						marchand_id: q.id,
						date: Time.now.strftime("%d-%m-%Y à %H:%M:%S"),
						expire: 5.minutes.from_now#.strftime("%T")
					}
				end
			end
        
    end

    #permet de declencher le paiement entre deux clients
    # @params from, to, amount, password
    # @details
    def payment
			#on decompose mes donnees recu depuis le client
			token = params[:token]

			#recherche du payeur
			customer = Customer.find_by_authentication_token(token)
			#from = params[:payeur]
			from = customer.id
			to = params[:receveur]
			amount = params[:montant]
			pwd = params[:password]

			transaction = Client::pay(from, to, amount, pwd)
			render json: {
				message: transaction
			}
    end


    #historique de l'utilisateur
    def user_history
        phone = params[:phone]
        render json: History::History::get_user_history(phone)
    end
    
end