class Api::V1::AgentController < ApplicationController

  #authenticate agent
  def signin
    #render json: agent = Agents::Auth::signin(params[:phone], params[:password])
    email       = params[:email]
    password    = params[:password]
    Partenaire::Authenticate.new(email, password)
    agent = P::Authenticate::signied(email, password)
    render json: {
        status:     agent[0],
        message:   agent[1]
      }
  end


  def search_customer
    @phone        = params[:phone]

    customer = Customer.find_by_phone(@phone)
    if customer.blank?
      render json: {
          status: false,
          message: "Utilisateur inconnu"
      }
    else
      render json: {
          status: true,
          message: customer.as_json(only: [:id, :name, :second_name, :phone, :sexe, :email, :created_at, :code])
      }
    end
  end

  def journal
    render json: {
        status: true,
        message: Transaction.all.order(date: :desc)
    }
  end

  def activate_customer
    @phone              = params[:phone]
    @authenticity_token = params[:authentication_token]
    @motif              = params[:motif]

    #startinf request
    customer = Customer.find_by_phone(@phone)
    if customer.blank?
      render json: {
          status: false,
          message: "Utilisateur inconnnu"
      }
    else
      #update customer data
      if customer.update(two_fa: "authenticate")
        render json: {
            status: true,
            message: "Utilisateur bloqué"
        }
      else
        render json: {
            status: false,
            message: "Impossible de bloquer cet utilisateur : #{customer.errors.full_messages}"
        }
      end
    end
  end


  def new_customer
    @cni          = params[:cni]
    @name         = params[:name]
    @second_name  = params[:second_name]
    @sexe         = params[:sexe]
    @phone        = params[:phone]
    #@agent_id     = params[:agent_id]

    #enregistrement des informations sur la creation
    query = P::Authenticate.partner_customer(@name, @second_name, @phone, @cni, @sexe)#P::Authenticate.new_customer(@name, @second_name, @phone, @cni, @agent_id)

    #on lance la creation d'ou nouveau compte client
    render json: {
      status: query[0],
      data:   query[1]
    }
  end


  def credit_customer

    @phone    = params[:phone]
    @amount   = params[:amount]

      credit = Client::credit_account(@phone, @amount)
      render json: {
          status: credit[0],
          message: credit[1]
      }

  end

  def debit_customer

    @phone    = params[:phone]
    @amount   = params[:amount]

    credit = Client::debit_user_account(@phone, @amount)
    render json: {
        status: credit[0],
        message: credit[1]
    }
  end


  #permet de lier un compte a un qrcode
  def link
    token = params[:token].split(" \" ")
    @qrcode = params[:qrcode]

    #insertion des information dans la base de données badge
    badge = Badge.new(
      customer_id: Customer.find_by_authentication_token(token).authentication_token,
      activate: true,
      qrcode: @qrcode
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