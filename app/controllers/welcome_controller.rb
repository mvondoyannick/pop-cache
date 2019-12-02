class WelcomeController < ApplicationController
  # before_action :authenticate_customer!
  # before_action :check_auth, only: [:home]

  def home
    render layout: "layouts/dashboard/application"
  end

  " login pmq customer"
  def login

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

    if hash.present? && token.present?
      #on recherche l'information a partir de ce hash
      data = History.find_by(code: hash, customer_id: token)
      if data.blank?
        render json: {
          message: "Cette transaction est inconnu"
        }
      else
        @data = data
        render layout: "layouts/dashboard/application"
      end
    else
      render json: {
        status: false,
        message: "Impossible de continuer, informations incomplete."
      }
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
