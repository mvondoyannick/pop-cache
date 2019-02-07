Api::V1::SessionController < ApplicationController

    #pour la connexion de l'utilisateur
    def create

    end

    def signin
        phone = params[:phone]
        password = params[:password]

        #query the user
        user = Customer.where(phone: phone).first

        if user.valid_password?(password)
            render json: user.as_json(only: [:id, :phone, :name, :second_name]), status: :created
        else
            head(:unauthorized)
        end
    end

    #pour la deconnexion de l'utilisateur
    def descroy
    end

end