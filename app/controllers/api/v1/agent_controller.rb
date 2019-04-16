class Api::V1::AgentController < ApplicationController

  #authenticate agent
  def signin
    #render json: agent = Agents::Auth::signin(params[:phone], params[:password])
    agent = Customer.find_by_phone(params[:phone])
    if agent.valid_password?(params[:password])
      render json: agent.as_json(only: [:name, :second_name, :authentication_token, :phone])
    else
      render json: {
        message: :unauthorize
      }
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
        message: "Badge innconnu"
      }
    else
      render json: query
    end
  end
end