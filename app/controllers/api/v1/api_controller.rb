class Api::V1::ApiController < AppliucationController

    #permet verifier un utilisateur
    def verif_user
        phone = params[:phone]

        #on recherche cet utilisateur
        user = Customer.where(phone: phone).first

        if user
            render json: user.as_json(only: [:name, :second_name]), status: :found
        else
            render json: {
                status: :not_found,
                message: 'unknow user'
            }
        end
    end


    #permet de verifier si le payeur dispose d'argent dans son compte
    def have_money
        
    end
end