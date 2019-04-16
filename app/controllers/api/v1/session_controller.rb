class Api::V1::SessionController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:signup, :signin, :validate_retrait, :signup_authentication, :service, :check_retrait, :histo]

    #creation de compte utilisateur
    def signup
      query = Client::create_user(params[:nom], params[:second_name], params[:phone], params[:cni], params[:password], params[:sexe])
      render json: {
        status: query
      }
    end


    def get_balance
        phone = params[:phone]
        password = params[:password]
        balance = Client::get_balance(phone, password)
        render json: balance
    end

    def histo #retourn l'historique sur la base du telephone
      #on recupere le header/token de l'utilisateur
      #header = request.headers['HTTP_X_API_POP_KEY']
      customer = Customer.find_by_authentication_token(request.headers['HTTP_X_API_POP_KEY']).id
      render json: {
        message: Transaction.where(customer: customer).order(created_at: :desc).as_json(only: [:date, :amount, :flag])
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

    

    #authentification d'un client mobile
    def signin
        phone = params[:phone]
        password = params[:password]

        #query the user
        signin = Client::auth_user(phone, password)
        render json: signin
    end

    #obtention du solde du compte client
    def solde
      @token = params[:customer]
      @pwd = params[:password]

      puts "=============#{@token}"

      #recherche du phone
      @customer = Customer.find_by_authentification_token(@token).phone
      if customer.blank?
        render json: {
          message: "Utilisateur inconnu sur la plateforme"
        }
      else
        @balance = Client::get_balance(@customer, @pwd)
        if balance
            render json: {
              message: @balance
            }
        else
            render json: {
                message: "compte vide"
            }
        end
      end
    end

    def getSoldeCustomer
      @phone = params[:customer]
      @pwd = params[:password]

      render json: {
        message: Client::get_balance(Customer.find_by_authentication_token(@phone).phone, @pwd)
      }

    end

    #verification du retrait
    def check_retrait
        header = request.headers['HTTP_X_API_POP_KEY']
        begin
          render json: {
            status: Client::check_retrait_refactoring(header) #Client::check_retrait(Customer.find(header).phone)
          }
        rescue => exception
          render json: {
            result: exception
          }
        end
    end

    #permet d'annuler le retrait en cours
    def cancel_retrait

    end

    def validate_retrait
        password = Base64.decode64(params[:password])
        puts "Mot de passe : #{password}"
        #header = request.headers['HTTP_X_API_POP_KEY']
        token = params[:token]

        request = Client::validate_retrait(token, password)
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