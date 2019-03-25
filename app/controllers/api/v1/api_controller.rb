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
			code  = params[:code]
			render json: {
					status: 200,
					content: code,
					qr_string: Parametre::Crypto::cryptoSSL(code)
			}
		end

    def qrcode
			data = Parametre::Crypto::decode(params[:data])
			puts data
			divide = data.split('#')
			#la premiere chaine correspond au payeur
			payeur = divide[0].split('@')
			payeur_phone = payeur[0]
			payeur_lat = payeur[1]
			payeur_long = payeur[2]
			puts "Le payeur : #{payeur}"
			# la seconde chaine correspond au QR code
			vendeur = divide[1].split('@')
			vendeur_phone = vendeur[0]
			vendeur_montant = vendeur[1]
			vendeur_lat = vendeur[2]
			vendeur_long = vendeur[3]
			context = vendeur[4]
			time = vendeur[5]

			#on veirfie le contexte qui peut etre soit phone ou plateforme
			if context == 'phone'
				puts "QR code from mobile "

				customer = Customer.where(phone: payeur_phone.to_i).first
				marchand = Customer.where(phone: vendeur_phone.to_i).first

				distance = DistanceMatrix::DistanceMatrix::get_distance(vendeur_lat, vendeur_long, payeur_lat, payeur_long)
				if customer.blank? || marchand.blank? || distance[0] == false
					render json: {
							message: :errors,
							description: "Erreur : #{distance[1]}",
							distance: distance[1]
					}
				else
					render json: {
							client_name: customer.name || 'fylo',
							client_second_name: customer.second_name,
							client_phone: customer.phone,
							marchand_name: marchand.name,
							marchand_second_name: marchand.second_name,
							marchand_phone: marchand.phone,
							amount: vendeur_montant,
							devise: "F CFA",
							country: :Cameroun,
							adresse_marchand: DistanceMatrix::DistanceMatrix::geocoder_search(vendeur_lat, vendeur_long),
							adresse_client: DistanceMatrix::DistanceMatrix::geocoder_search(payeur_lat, payeur_long),
							distance_status: distance[0],
							date: Time.now
					}
				end
			else
				puts "QR code from plateforme"
			end
        
    end

    #permet de declencher le paiement entre deux clients
    # @params from, to, amount, password
    # @details
    def payment
			#on decompose mes donnees recu depuis le client
			from = params[:payeur]
			to = params[:receveur]
			amount = params[:montant]
			pwd = params[:password]

			if !from.nil? && !pwd.nil?
					#--------------------------------------------------
					#creation du journale de transaction
					#Logs::Journal::create_logs_transaction(from, to, amount, )

					transaction = Client::pay(from, to, amount, pwd)
					puts transaction
					render json: transaction
			else
					render json: {
            message: "failed",
            description: "Aucuns parametres recu"
					}
			end
    end


    #historique de l'utilisateur
    def user_history
        phone = params[:phone]
        render json: History::History::get_user_history(phone)
    end
    
end