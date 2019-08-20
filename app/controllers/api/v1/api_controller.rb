class Api::V1::ApiController < ApplicationController

  before_action :check_customer, except: :searchContext

  # PAY WITH MERCHANT OR PHONE QRCODE
  def qrcode

    #integration de la gestion des erreurs 1.0
    # Il est important de noter que chaque transaction de QRCODE generé par le telephone
    # contient une clé unique, cela permet a quelqu'un qui a deja payé cette transaction via
    # ce QRCODE ne le repaye pas par erreur
    # Add new params
    # qr_id 	= params[:qrid]
    # TODO Update and add qrid to qrcode mobile app and add token header key

    begin

      data = Base64.strict_decode64(params[:data]).split("#")

      #recheche du payeur
      payeur_data = data[0]

      #information du marchand
      marchand_data = data[1]

      #extraction des informations du payeur
      payeur = payeur_data.split("@")

      @payeur = Customer.find_by_authentication_token(payeur[0])
      if @payeur.blank?
        puts "Impossible de trouver ce customer"
        render json: {
            status: 404,
            flag: :customer_not_found,
            message: "Impossible de trouver cet utilisateur"
        }
      else
        Rails::logger::info "Recherche des informations sur le marchand"
        marchand = marchand_data.split("@")
        @marchand = Customer.find_by_authentication_token(marchand[0])
        if @marchand.blank?
          render json: {
              status: 404,
              flag: :customer_not_found,
              message: "Ce marchand est inconnu."
          }
        else
          Rails::logger::info "#{marchand[4]} ++ #{marchand[1]} ++ #{marchand[0]}"
          render json: {
              message: true,
              context: marchand[4],
              name: @marchand.name,
              second_name: @marchand.second_name,
              amount: marchand[1],
              marchand_id: @marchand.authentication_token, #q.id,
              date: Time.now.strftime("%d-%m-%Y à %H:%M:%S"),
              expire: 5.minutes.from_now #.strftime("%T")
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

  #PAY WITH PHONE NUMBER
  def phonePayment
    @token = request.headers['HTTP_X_API_POP_KEY']
    @playerID = params[:oneSignalID]
    @phone = params[:phone]
    @amount = params[:amount]
    @password = params[:password]
    @ip = request.remote_ip

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
          payment = External::DemoUsers.Payment(token: @token, password: @password, phone: @phone, amount: @amount, ip: @ip, oneSignalID: @playerID)
          puts "From Payment : #{payment}"
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


  #PAY WITH MIN MERCHANT CODE
  # @param @code
  # @param @token
  # TODO request token inside each API header un payment
  def code
    @code = params[:code]
    @token = request.headers["HTTP_X_API_POP_KEY"]
    @ip = request.remote_ip

    begin

      #uniquement si le code est un entier
      @customer = Customer.find_by_code(@code)
      if @customer.blank?
        render json: {
            message: false,
            flag: :customer_not_found
        }
      else
        #on retourne les informations

        render json: {
          message: true,
          context: searchContext(@customer),
          name: @customer.name,
          second_name: @customer.second_name,
          marchand_id: @customer.authentication_token,
          date: Time.now.strftime("%d-%m-%Y à %H:%M:%S"),
          expire: 5.minutes.from_now
        }
      end
      
    rescue ActiveRecord::RecordNotFound

      render json: {
        message: false,
        content: "Utilisateur inconnu"
      }
      
    end


  end

  #SEARCH QRCODE CONTEXT
  # @param [Object] obj
  def searchContext(obj)
    if "plateform".in?(obj.hand)
      return "plateform"
    elsif "mobile".in?(obj.hand)
      return "mobile"
    end
  end

  #CUSTOMER AMOUNT DYNAMICALY
  def customer_account_amount
    puts "Starting dynamically render amount ..."
    token = request.headers["HTTP_X_API_POP_KEY"]
    customer = Customer.find_by_authentication_token(token)
    if customer.blank?
      Rails::logger.info "Nos customer found"
      render json: {
        status: :false,
        message: "Utilisateur inconnu"
      },
      status: :unauthorized
    else
      if customer.account.blank?
        puts "This customer does not activate his account"
        render json: {
          status: false,
          message: "Compte inexistant pour ce compte"
        },
        status: :unauthorized
      else
        Rails::logger.info "Customer founds and has result of his request"
        render json: {
          status: true,
          message: customer.account.amount.round(2)
        },
        status: :ok
      end
    end
  end

  #PAYMENT PROCESS
  # @details
  # @return [Object]
  # TODO add token to filter params header before_action
  def payment
    customer = params[:token]
    merchant = params[:receveur]
    amount = params[:montant]
    pwd = params[:password]

    @token = request.headers["HTTP_X_API_POP_KEY"]
    locale = "en" #request.headers["HTTP_LOCALE"]#.split("-") #fr-FR become ["fr", "FR"]

    @ip = request.remote_ip
    @lat = params[:lat] #Base64.decode64(params[:lat])
    @lon = params[:long] #Base64.decode64(params[:long])

      #recuperation du onesignalID
      # @player_id = Base64.decode64(params[:oneSignalID])

      # Rails::logger::info "oneSignalId : #{@player_id}"

      #@customer = Customer.find_by_authentication_token(from) if Customer.exists?(authentication_token: from)
      #@marchand = Customer.find_by_authentication_token(to) if Customer.exists?(authentication_token: to)

      #OneSignal::OneSignalSend.sendNotification(@player_id, amount, "#{@marchand.name} #{@marchand.second_name}", "#{@customer.name} #{@customer.second_name}")
      transaction = Client::pay({customer: customer, merchant: merchant, amount: amount, password: pwd, ip: @ip, lat: @lat, lon: @lon},"Paiement", locale)
      # transaction = Client::Payment.pay(customer: @customer.id, merchant: @merchant.id, amount: amount, password: pwd, ip: @ip, player_id: @player_id, lat: @lat, lon: @lon)
      render json: {
          message: transaction
      }
  end

  private

  def check_customer
    @token = request.headers["HTTP_X_API_POP_KEY"]
    @uuid = request.headers["HTTP_UUID"]

    puts "Header data receive : Token #{@token}, UUID : #{@uuid}"

    begin
      customer = Customer.find_by(authentication_token: @token, two_fa: 'authenticate')
      if customer.blank?
        #response.set_header('HEADER NAME', :unauthorized)
        #render json: {
        #  status: :unauthorized,
        #  message: "Utilisateur non autorisé"
        #}
        head :unauthorized
      end
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: false,
          message: "Utilisateur inconnu"
        }
    end
    #Rails::logger.info "The token receive is #{request.headers["HTTP_X_API_POP_KEY"]}"
  end

end