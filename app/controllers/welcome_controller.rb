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
    end
  end
end
