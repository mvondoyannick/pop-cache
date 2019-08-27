class WelcomeController < ApplicationController
  def home
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
      render layout: "layouts/webview"

    else
      @result = "Impossible de terminer la transaction"
      render layout: "layouts/webview"
    end
    #puts "Data receive : #{params[:application][:notes]}"
  end
end
