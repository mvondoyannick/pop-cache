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


    #permet de verifier si le payeur dispose d'argent dans son compte
    def have_money
        
    end


    def qrcode
        data = params[:data]
        puts data
        current = data.split('@')
        puts current
        customer = Customer.where(phone: current[0]).first
        marchand = Customer.where(phone: current[2]).first
        #gestion des coordonnées
        marchand_lat = current[3]
        marchand_lon = current[4]
        customer_lat = current[5]
        customer_lon = current[6]

        #on verifie la distance matrix entre les deux utilisateurs
        distance = DistanceMatrix::get_distance(marchand_lat, marchand_lon, customer_lat, customer_lon)
        if distance[0] == true
            if customer && marchand
                render json: {
                    client_name: customer.name,
                    client_second_name: customer.second_name,
                    client_phone: customer.phone,
                    marchand_name: marchand.name,
                    marchand_second_name: marchand.second_name,
                    marchand_phone: marchand.phone,
                    amount: current[1].to_i,
                    devise: "F CFA",
                    country: :Cameroun,
                    adresse_marchand: DistanceMatrix::geocoder_search(marchand_lat, marchand_lon),
                    adresse_client: DistanceMatrix::geocoder_search(customer_lat, customer_lon),
                }
            else
                render json: {
                    message: :errors,
                    description: "Des erreurs sont survenues",
                    code_erreurs: customer.errors.messages || marchand.errors.messages
                }
            end
        else
            render json: {
                code: distance[0],
                message: distance[1],
                distance: distance[2].abs
            }
        end
        
    end

    #permet de declencher le paiement
    def payment
        #on decompose mes donnees recu depuis le client
        from = params[:payeur]
        to = params[:receveur]
        amount = params[:montant]
        pwd = params[:password]

        if !from.nil? && !pwd.nil?
            #--------------------------------------------------
            #creation du journale de transaction
            Journal::create_logs_transaction(from, to, amount)

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