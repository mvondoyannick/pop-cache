class WelcomeController < ApplicationController
  # before_action :authenticate_customer!
  # before_action :check_auth, only: [:home]

  def home
    @new_registration = Customer.where(created_at: Date.today.beginning_of_week..Date.today.end_of_week).count
    @day_paiements = History.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).limit(5).reverse
    @day_commission = Commission.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).sum(:commission)
    render layout: "layouts/dashboard/application"
  end

  # user profile
  def profile
    render layout: "layouts/dashboard/application"
  end

  #show all users
  def users 
    @users = Customer.all.order(name: :asc).where(two_fa: "authenticate")
    @not_auth = Customer.all.order(name: :asc).where(two_fa: nil)
    render layout: "layouts/dashboard/application"
  end

  # show singular user
  def user 
    token = params[:token]
    if Customer.exists?(authentication_token: token)
      @user = Customer.find_by(authentication_token: token)
      @history = History.all.where(customer_id: @user.id)
      @status = true
    else
      @status = false
    end
    render layout: "layouts/dashboard/application"
  end

  # login pmq customer
  def login
    id = params[:token]
    @token = Customer.find(id).authentication_token
    render layout: "layouts/dashboard/application"
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

  def webview_login
  end


  def webview_signup
  end


  def webview_history
  end


  def webview_pay
  end

  
  def webview_home
  end

  # recharge utilisateur par l'admin
  def recharge
    render layout: "layouts/dashboard/application"
  end

  # retrai t utilisateur par l'admin ou le partenaire
  def retrait
    @notice = nil
    if params[:phone].present? && params[:montant].present?
      phone = params[:phone].to_i
      montant = params[:montant]

      # searching customer with phone
      if Customer.exists?(phone: phone)
        # begin transaction

        a = Client.debit_user_account(phone, montant)

        puts a

        @notice = true

      else

        #flash[:notice] = "Numero inexistant sur la plateforme"
        @notice = "Numéro inconnu"
        redirect_to "/admin/users/retrait"
        return

      end
    end
    render layout: "layouts/dashboard/application"
  end

  # confirm retrait
  def confirm_retrait

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
