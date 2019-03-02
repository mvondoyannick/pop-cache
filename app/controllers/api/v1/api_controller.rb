class Api::V1::ApiController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:payment, :qrcode]

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

    def qrcode
			data = Parametre::Crypto::decode(params[:data])
			puts data
			current = data.split('@')
      customer = Customer.where(phone: current[0]).first
      puts '============================================='
      #puts Parametre::Crypto::decode(current[1]).split('@')
      currated_marchant = Parametre::Crypto::decode(current[1]).split('@')
      puts '============================================='
      marchand = Customer.where(phone: currated_marchant[1]).first
			#gestion des coordonnées
			marchand_lat = currated_marchant[2]
			marchand_lon = currated_marchant[3]
			customer_lat = current[2]
      customer_lon = current[3]

			#on verifie la distance matrix entre les deux utilisateurs
			distance = DistanceMatrix::DistanceMatrix::get_distance(marchand_lat, marchand_lon, customer_lat, customer_lon)
			if customer.blank? || marchand.blank? || distance[0] == false
				render json: {
					message: :errors,
          description: "Erreur : #{distance[1]}",
          distance: distance[1]
					#code_erreurs: customer.errors.messages || marchand.errors.messages
				}
      else
        render json: {
					client_name: customer.name || 'fylo',
					client_second_name: customer.second_name,
					client_phone: customer.phone,
					marchand_name: marchand.name,
					marchand_second_name: marchand.second_name,
					marchand_phone: marchand.phone,
					amount: currated_marchant[0].to_i,
					devise: "F CFA",
					country: :Cameroun,
					adresse_marchand: DistanceMatrix::DistanceMatrix::geocoder_search(marchand_lat, marchand_lon),
          adresse_client: DistanceMatrix::DistanceMatrix::geocoder_search(customer_lat, customer_lon),
          distance_status: distance[0],
          date: Time.now
					}
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
        render json: History::get_user_history(phone)
    end
    
end