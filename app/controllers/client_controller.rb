class ClientController < ApplicationController
  def signing
    #render layout: 'client/application'
  end

  #permet de valider les informations de connexion du partenaire
  def attemp_login
    login     = params[:email_or_phone]
    password  = params[:password]

    unless !(login.present? && password.present?)
      #on recherche le customer
      @customer = Customer.find_by_phone(login)
      if @customer.blank?
        respond_to do |format|
          format.json {}
          format.html {render :signing, notice: "Impossible de trouver #{login}"}
        end
      else
        if @customer.valid_password?(password)
          session[:customer] = @customer.authentication_token
          respond_to do |format|
            format.html { redirect_to client_index_path(user: @customer.hand), notice: "Logged in as #{@customer.phone}"}
          end
        else
          respond_to do |format|
            format.html {redirect_to client_signing_path, notice: "Utilisateur inconnu"}
          end
        end
      end
    end
  end

  #register new account
  def signup
    render layout: 'client/application'
  end

  #traitement de la requete de creation de  compte sur la plateforme
  def attemp_signup

  end

  def parameters
  end

  def index
    #@client = Transaction.where(phone: current_customer.phone)
    render layout: "application"
  end
end
