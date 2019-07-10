class Api::V1::ApiController < ApplicationController

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

			#integration de la gestion des erreurs 1.0
			# Il est important de noter que chaque transaction de QRCODE generé par le telephone
			# contient une clé unique, cela permet a quelqu'un qui a deja payé cette transaction via
			# ce QRCODE ne le repaye pas par erreur
			# Add new params
			# qr_id 	= params[:qrid]
			# TODO Update and add qrid to qrcode mobile app

			begin

				#data = Parametre::Crypto::decode(params[:data])
				data = Base64.strict_decode64(params[:data]).split("#") #Base64.decode64(params[:data]).split("#")

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

			rescue ArgumentError => e

				render json: {
					message: false,
					content: "Impossible de lire ce Qr Code : #{e}"
				}


			end

		end

    #paiement avec un numero de telephone pour quelqu'un qui n'est pas sur la plateforme
    # @!method POST
		def phonePayment
			@token 		= request.headers['HTTP_X_API_POP_KEY']
			@phone 		= params[:phone]
			@amount 	= params[:amount]
			@password = params[:password]

			puts "This is token : #{@token}"

			begin

				#Recherche de ce numero sur la plateforme
				# check token of sender of request
				if @token.present? && @phone.present? && @amount.present? && @password.present?
					customer = Customer.find_by_authentication_token(@token)
					if customer.blank?
						render json: {
							status: false,
							message: "Utilisateur inconnu"
						}
					else
						#tout va bien, l'utilisateur payeur est connu, check the phone number
						#find if this number is not registrated to the plateforme
						payment = External::DemoUsers.Payment(token: @token, password: @password, phone: @phone, amount: @amount)
						Rails::logger.info "From Payment : #{payment}"
						render json: {
							status: payment[0],
							message: payment[1]
						}

					end
				else
					render json: {
						status: false,
						message: "Certaines informations sont absentes."
					}
				end

			rescue ActiveRecord::RecordNotFound

				render json: {
					status: false,
					message: "Utilisateur inconnu de la plateforme"
				}

			end

		end


    #recherche via le code marchand
    def code
			@code = params[:code].to_i

			if @code.present?

				if @code.is_a?(Integer)
					#uniquement si le code est un entier
					@customer = Customer.find_by_code(@code)
					if @customer.blank?
						render json: {
							message: false,
							flag: :customer_not_found
						}
					else
						#on retourne les informations
						puts @customer.code
						render json: {
								message: true,
								context: searchContext(@customer),
								name:	@customer.name,
								second_name: @customer.second_name,
								marchand_id: @customer.authentication_token,
								date: Time.now.strftime("%d-%m-%Y à %H:%M:%S"),
								expire: 5.minutes.from_now
						}
					end
				else
					render json: {
						message: "varable incorrecte"
					}
				end

			else

				render json: {

					message: false,
					content: "Certaines informations sont manquantes ou incorrecte"

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
    # @details
	# @return [Object]
	def payment
			from = params[:token]
			to = params[:receveur]
			amount = params[:montant]
			pwd = params[:password]
			@ip = request.remote_ip
			@lat = params[:lat] #Base64.decode64(params[:lat])
      		@lon = params[:long] #Base64.decode64(params[:long])
      
      begin

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

        rescue ArgumentError => e
          Rails::logger.warn "Une erreur est survenue durant de deryptage : #{e}"

          render json: {
            status: :qrcode_failed,
            message: "QR Code invalide"
          }
      end

    end
    
end