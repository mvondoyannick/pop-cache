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
				Rails::logger::info "Impossible de trouver ce customer"
				render json: {
					status: 	404,
					flag: 		:customer_not_found,
					message: 	"Impossible de trouver cet utilisateur"
				}
			else
				Rails::logger::info "Recherche des informations sur le marchand"
				ex_marchand = marchand_global.split("@")
				q = Customer.find_by_authentication_token(ex_marchand[0])
				if q.blank?
					render json: {
						status: 	404,
						flag: 		:customer_not_found,
						message: "Impossible de trouver ce marchand."
					}
				else
					Rails::logger::info "#{ex_marchand[4]} ++ #{ex_marchand[1]} ++ #{ex_marchand[0]}"
					render json:{
						message: true,
						context: ex_marchand[4],
						name: q.name,
						second_name: q.second_name,
						amount: ex_marchand[1],
						marchand_id: q.authentication_token, #q.id,
						date: Time.now.strftime("%d-%m-%Y à %H:%M:%S"),
						expire: 5.minutes.from_now#.strftime("%T")
					}
				end
			end
		end


    #recherche via le code marchand
    def code
			@code = params[:code].to_i

			if @code.is_a?(Integer)
				#uniquement si le code est un entier
				@customer = Customer.find_by_code(@code)
				if @customer.blank?
					render json: {
						message: 			false,
						flag: 				:customer_not_found
					}
				else
					#on retourne les informations
					puts @customer.code
					render json: {
						message: 			true,
						context: 			searchContext(@customer),
						name:					@customer.name,
						second_name: 	@customer.second_name,
						marchand_id:  @customer.authentication_token,
						date: 				Time.now.strftime("%d-%m-%Y à %H:%M:%S"),
						expire: 			5.minutes.from_now
					}
				end
			else
				render json: {
						message: "varable incorrecte"
				}
			end
		end

    #recherche le context plateforme ou mobile dans un qrcode
    def searchContext(obj)
			if "plateform".in?(obj.hand)
				return "plateform"
			elsif "mobile".in?(obj.hand)
				return "mobile"
			end
		end

    #permet de declencher le paiement entre deux clients
    # @params from, to, amount, password
    # @details
		# @return [Object]
		def payment
			from 				= params[:token]
			to 					= params[:receveur]
			amount 			= params[:montant]
			pwd 				= params[:password]
			@ip 				= request.remote_ip
			@lat 				= Base64.decode64(params[:lat])
			@lon 				= Base64.decode64(params[:long])

			#recuperation du onesignalID
			@player_id = Base64.decode64(params[:oneSignalID])

			Rails::logger::info "oneSignalId : #{@player_id}"

			@customer = Customer.find_by_authentication_token(from)
			@marchand = Customer.find_by_authentication_token(to)
			if @customer.blank? && @marchand.blank?
				render json: {
						status: 	404,
						flag: 		:customer_not_found,
						message: 	"Utilisateur inconnu"
				}
			else
				#OneSignal::OneSignalSend.sendNotification(@player_id, amount, "#{@marchand.name} #{@marchand.second_name}", "#{@customer.name} #{@customer.second_name}")
				transaction = Client::pay(@customer.id, @marchand.id, amount, pwd, @ip, @player_id, @lat, @lon)
				render json: {
						message: transaction
				}
			end
    end


    #historique de l'utilisateur
    def user_history
        phone = params[:phone]
        render json: History::History::get_user_history(phone)
		end

  # effectuer le paiement d'une transaction via USSD
  def paymentUssdExt
		render plain: "Welcome"
	end
    
end