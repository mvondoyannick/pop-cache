class Api::V1::AgentController < ApplicationController
  # skip_before_action :verify_authenticity_token, only: [:signin]

  #authenticate agent
  def signin
    #render json: agent = Agents::Auth::signin(params[:phone], params[:password])
    # agent = Customer.find_by_phone(params[:phone])
    # if agent.valid_password?(params[:password])
    #   render json: agent.as_json(only: [:name, :second_name, :authentication_token, :phone])
    # else
    #   render json: {
    #     message: :unauthorize
    #   }
    # end
    @email      = params[:email]
    @password   = params[:password]

    Partenaire::Authenticate.new(email: @email, password: @password)
    @agent = Partenaire::Authenticate.signin
    render json: {
        status:     @agent[0],
        response:   @agent[1]
    }
  end


  #permet de lier un compte a un qrcode
  def link
    token = params[:token].split(" \" ")
    qrcode = params[:qrcode]

    #insertion des information dans la base de données badge
    badge = Badge.new(
      customer_id: Customer.find_by_authentication_token(token).authentication_token,
      activate:   true,
      qrcode:     qrcode
    )

    # on enregistre
    if badge.save
      render json: {
        status:   200,
        message:  "Liaision etablie"
      }
    else
      render json: {
        status:   404,
        message:  badge.errors.full_messages
      }
    end
  end

  #search customer by phone
  def searchCustomerByPhone
    phone = params[:phone]
    customer = Customer.find_by_phone(phone)

    if customer.blank?
      render json: {
        status:   :false,
        flag:     :unknow,
        message:  "Utilisateur Inconnu"
      }
    else
      #render json: customer
      #on recherche le badge
      badge = Badge.find_by_customer_id(customer.id)
      if badge.blank?
        render json: {
          status:   :true,
          flag:     :no_badge,
          message:  "Aucun badge rataché a cet utilisateur",
          data:     customer.as_json(only: [:name, :second_name, :phone, :authentication_token, :sexe, :phone, :cni])
        }
      else
        render json: {
          status: :false,
          flag:   :have_badge,
          message: "Utilisateur deja lié à un badge, ajout impossible."
        }
      end
    end
  end

  #search qrcode code
  def searchQrcodeByCode
    code = params[:code]

  end

  #permet la mise a jour des informations provenant du mobile des agents
  def update
    customer = Customer.find_by_authentication_token(params[:token])
    pwd = 111111 #SecureRandom.hex(4)
    if customer.blank?
      render json: {
        message: "Impossible d'activer ce badge"
      }
    else
      #on met à jour les informations
      query = customer.update(
        name:         params[:name],
        second_name:  params[:second_name],
        cni:          params[:cni],
        phone:        params[:phone],
        sexe:         params[:sexe],
        two_fa:       params[:authenticated],
        password:     pwd
      )

      #verification de la mise a jour
      Sms.new(params[:phone], "Votre mot de passe est #{pwd}, conservez en toute securité")
    end
  end


  #search by scan
  def searchQrCodeByScan
    data = params[:data]

    #break the chain
    data = Base64.decode64(data).split("@");
    token = data[0]

    #on effectue la recherche
    query = Customer.find_by_authentication_token(token)
    if query.blank?
      render json: {
        message: "Badge inconnu"
      }
    else
      render json: query
    end
  end
end