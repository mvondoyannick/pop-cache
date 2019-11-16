class WelcomeController < ApplicationController
  #before_action :authenticate_customer!
  # before_action :check_auth, only: [:home]

  def home
    puts "session id: #{session[:user_id]}"
    render layout: "layouts/dashboard/application"
  end

  " login pmq customer"
  def login
    
  end

  def auth
    puts "lorem loading ...s"
    phone = params[:phone]
    password = params[:password]
    user = Customer.find_by_phone(phone)
    puts "Password valid? : #{user.valid_password?(password)}"
    if user && user.valid_password?(password)
      puts "found #{user.complete_name}."
      session[:token] = {value: user.authentication_token, expires_in: 1.hour}
      redirect_to dashboard_path, session[:token]
    else
      render "login"
    end
  end

  def accounts
    render layout: "layouts/dashboard/application"
  end

  def enterprise
  end

  def particulier
  end

  def webview

    hash = params[:hash]
    token = params[:token]

    #on recherche l'information a partir de ce hash
    data = History.find_by(code: hash, customer_id: token)
    if data.blank?
      render json: {
        message: "Cette transaction est inconnu"
      }
    else
      @data = data
      render layout: "layouts/webview"
    end
  end

  def mppp
    if params[:commit] == "Envoyer"
      # commited has been received

      Sms.mppp(params[:application][:notes])
      #flash[:success] = "SMS envoyé aux membres du MPPP. Merci"
      render layout: "layouts/webview"

    else
      @result = "Impossible de terminer la transaction"
      render layout: "layouts/webview"
    end
    #puts "Data receive : #{params[:application][:notes]}"
  end

  private
  def check_auth
    if session[:user_id]
      user = Customer.find_by_authentication_token(session[:user_id])
      if user
        redirect_to root_path
      else
        render "login"
      end
    else
      puts "not logged in"
      render "login" #new_customer_session_path
    end
  end
end
