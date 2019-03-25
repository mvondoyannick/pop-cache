class Api::V1::SessionController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:signup, :signin, :validate_retrait, :signup_authentication, :service]

    #creation de compte utilisateur
    def signup
        email = "me@me.com"
        query = Client::create_user(params[:nom], params[:prenom], params[:phone], params[:password])
        render json: {
          status: query
        }

        #processus de creation des comptes utilisateurs
    end


    def get_balance
        phone = params[:phone]
        password = params[:password]
        balance = Client::get_balance(phone, password)
        render json: balance
    end

    def e #retourn l'historique sur la base du telephone
      phone = params[:phone]
      query = History::History::encaisser(phone)
      render json: {
          message: query
      }
    end


    #retourne toutes les categories
    def serviceCategorie
      categorie = Cat.order(name: :asc)
      render json: {
          categories: categorie
      }
    end

    #retourne les details d'une categorie
    def detailCategorie
      id = params[:id]
      detailCat = Cat.where(cat_id: id, name: :asc)
      render json: {
          cat_detail: detailCat
      }
    end

    #permet de lister l'ensemble des services dans une categorie
    def service

      id = params[:id]
      services = Service.where(cat_id: id)
      render json: {
          services: services
      }

    end

    def p
      phone = params[:phone]
      query = History::History::payment(phone)
      render json: {
          message: query
      }
    end

    

    def signin
        phone = params[:phone]
        password = params[:password]

        #query the user
        signin = Client::auth_user(phone, password)
        render json: signin
    end

    #obtention du solde du compte client
    def solde
        phone = params[:phone]
        pwd = params[:password]

        balance = Client::get_balance(phone, pwd)
        if balance
            render json: balance
        else
            render json: {
                message: "compte vide"
            }
        end
    end

    #verification du retrait
    def check_retrait
        phone = params[:phone]
        request = Client::check_retrait(phone)
        if request && request[0] == true
          render json: {
            status: true,
            message: request[1]
          }
        else
          render json: {
            status: false,
            message: request[1]
          }
        end
    end

    def validate_retrait
        phone = params[:phone]
        password = params[:password]
        puts params
        request = Client::validate_retrait(phone, password)
        if request && request[0] == true
            render json: {
              code: request[0],
              message: request[1]
            }
        else
          render json: {
            code: request[0],
            message: request[1]
          }
        end
    end

    #validation de 2FA
    def signup_authentication
      phone = params[:phone]
      code  = params[:code]

      authenticate = Parametre::Authentication::validate_2fa(phone, code)
      if authenticate[0] == true
        render json: {
          status: :success,
          message: "Authentifié"
        }
      else
        render json: {
          status: :failed,
          message: "Echec authentification"
        }
      end
    end
  


    def transaction
        from = params[:payeur]
        to = params[:receveur]
        amount = params[:montant]
        password = params[:password]

        transaction = Client::transaction(from, to, amount, password)
        render json: transaction
    end

    private

    def account_params
        params.require(:customer).permit(:name, :second_name, :cni, :phone)
    end

end