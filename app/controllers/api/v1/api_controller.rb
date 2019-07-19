class Api::V1::ApiController < ApplicationController

  before_action :check_customer, except: :searchContext

  def qrcode

    #integration de la gestion des erreurs 1.0
    # Il est important de noter que chaque transaction de QRCODE generé par le telephone
    # contient une clé unique, cela permet a quelqu'un qui a deja payé cette transaction via
    # ce QRCODE ne le repaye pas par erreur
    # Add new params
    # qr_id 	= params[:qrid]
    # TODO Update and add qrid to qrcode mobile app and add token header key

    begin

      #data = Parametre::Crypto::decode(params[:data])
      data = Base64.strict_decode64(params[:data]).split("#") #Base64.decode64(params[:data]).split("#")
      token = request.headers["HTTP_X_API_POP_KEY"]

      #recheche du payeur
      payeur_data = data[0]

      #information du marchand
      marchand_data = data[1]

      #extraction des informations du payeur
      payeur = payeur_data.split("@")

      @payeur = Customer.find_by_authentication_token(payeur[0])
      if @payeur.blank?
        Rails::logger::info "Impossible de trouver ce customer"
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

  #paiement avec un numero de telephone pour quelqu'un qui n'est pas sur la plateforme
  # @!method POST
  def phonePayment
    @token = request.headers['HTTP_X_API_POP_KEY']
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
          payment = External::DemoUsers.Payment(token: @token, password: @password, phone: @phone, amount: @amount, ip: @ip)
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


  # recherche via le code marchand
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
  # TODO add token to filter params header before_action
  def payment
    from = params[:token]
    to = params[:receveur]
    amount = params[:montant]
    pwd = params[:password]

    @token = request.headers["HTTP_X_API_POP_KEY"]

    @ip = request.remote_ip
    @lat = params[:lat] #Base64.decode64(params[:lat])
    @lon = params[:long] #Base64.decode64(params[:long])

    begin

      #recuperation du onesignalID
      # @player_id = Base64.decode64(params[:oneSignalID])

      # Rails::logger::info "oneSignalId : #{@player_id}"

      @customer = Customer.find_by_authentication_token(from)
      @marchand = Customer.find_by_authentication_token(to)
      if @customer.blank? && @marchand.blank?
        render json: {
            status: 404,
            flag: :customer_not_found,
            message: "Utilisateur inconnu"
        }
      else
        #OneSignal::OneSignalSend.sendNotification(@player_id, amount, "#{@marchand.name} #{@marchand.second_name}", "#{@customer.name} #{@customer.second_name}")
        transaction = Client::pay(@customer.id, @marchand.id, amount, pwd, @ip, @lat, @lon)
        # transaction = Client::Payment.pay(customer: @customer.id, merchant: @merchant.id, amount: amount, password: pwd, ip: @ip, player_id: @player_id, lat: @lat, lon: @lon)
        #
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

  private

  def check_customer
    @token = request.headers["HTTP_X_API_POP_KEY"]
    @uuid = request.headers["HTTP_UUID"]

    Rails::logger::info "Header data receive : Token #{@token}, Uuid : #{@uuid}"

    begin
      customer = Customer.find_by(authentication_token: @token, device: @uuid, two_fa: 'authenticate')
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