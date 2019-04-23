class Api::V1::SessionController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:signup, :signin, :validate_retrait, :signup_authentication, :service, :check_retrait, :histo, :retrivePassword, :resetPassword, :rechargeSprintPay, :getPhoneNumber]

    #creation de compte utilisateur
    def signup
      query = Client::signup(params[:nom], params[:second_name], params[:phone], params[:cni], params[:password], params[:sexe], params[:question_id], params[:reponse], params[:lat], params[:lon])
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
      @customer = Customer.find_by_authentication_token(request.headers['HTTP_X_API_POP_KEY'])
      if @customer.blank?
        render json: {
            status:   :not_found,
            message:  "utilisateur inconnu"
        }
      else
        render json: {
            message: Transaction.where(customer: @customer.id).order(created_at: :desc).as_json(only: [:date, :amount, :flag])
        }
      end
    end

    # gestion des questions de securité
    # retourne toutes les question de securité  dispnible sur la plateforme
    # 
    def question
      question = Question.all
      render json: {
        message: question.as_json(only: [:id, :content])
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


    # recuperation du mot de passe perdu/oublié par le customer
    def retrivePassword
      question  = params[:question_id]
      answer    = params[:reponse]
      phone     = params[:phone]

      @sms_pwd = rand(6**6)

      # on recherche si ce numero de telephone est enregistré dans la plateforme
      customer = Customer.find_by_phone(phone)
      if customer.blank?
        render json: {
          status: :not_found,
          message:  "Utilisateur inconnu"
        }
      else
        answer = Answer.where(customer_id: customer.id, question_id: question, content: answer).first
        if answer.blank?
          Rails::logger::info "#{answer.inspect}"
          render json: {
            status:   :not_found,
            message:  "Resultat non coherent pour l'utilisateur #{phone}"
          }
        else
          # avant l'envoi, on bloque le compte du customer
          lock = Parametre::SecurityQuestion::lockCustomerAccount(customer.id)

          Rails::logger::info "Valeur de Lock :: #{lock.inspect}"

          if lock[0] == true 
            # on enregistre le code SMS
            sms_code = SmsPassword.new(customer_id: customer.id, code: @sms_pwd)
            if sms_code.save
              # on incremente le compte status

              #le compte vient d'etre bloqué
              Sms.new(customer.phone, "SMS Validation mot de passe #{@sms_pwd}")
              Sms::send
              render json: {
                status:   :found,
                message:  "Verifier votre messagerie SMS."
              }
            else
              render json: {
                status:   :errors,
                message:  "Une erreur est survenue"
              }
            end
          else
            render json: {
              status:   :error_lock,
              message:  "Impossible de verrouiller le compte"
            }
          end
        end
      end
    end

    # permet  de reset le password
    def resetPassword
      code                  = params[:code_sms]
      phone                 = params[:phone]
      password              = params[:password]

      # on cherche a verifier le code
      customer = Customer.find_by_phone(phone)
      if customer.blank?
        render json: {
          status: :not_found,
          message:  "Utilisateur inconnu"
        }
      else
        # on commence par rechercher si le customer en question a demander a reinitialiser son pwd
        checkCode = SmsPassword.where(customer_id: customer.id, code: code).first
        if checkCode.blank?
          render json: {
            status:   :not_found,
            message:  "Pas de code pour cet utilisateur"
          }
        else
          # deblocage du user
          unlock = Parametre::SecurityQuestion::unlockCustomerAccount(customer.id)
          if unlock[0] == true
            if customer.update(password: password)

              # on supprimer les anciennes informations
              if checkCode.destroy
                Sms.new(customer.phone, "Votre mot de passe vient d etre mis a jour si vous n en etes pas l auteur, veillez vous rapprocher d un agence partenaire. POPCASH")
                #render data to json
                render json: {
                  status:   :success,
                  message:  "Mot de passe mis a jour"
                }
              else
                #render data to json
                render json: {
                  status:   :failed,
                  message:  "Impossible de mettre le mot de passe a jour",
                  errors:   checkCode.errors.full_messages
                }
              end
            else
              render json: {
                status:   :error,
                message:  "Impossible de mettre le mot de passe jour"
              }
            end
          else
            render json: {
              status:   :errors,
              message:  "Mise à jour d'informations d'authetification impossible"
            }
          end
        end
      end
    end

    # retourn le numero sur la base tu header
    # @return [Object]
    def getPhoneNumber
      header = request.headers['HTTP_X_API_POP_KEY']

      # on recherche le customer
      @customer = Customer.find_by_authentication_token(header)
      if @customer.blank?
        render json: {
            status:   :not_found,
            message:  "Utilisateur inconnu"
        }
      else
        render json: {
            status:   :found,
            message:  @customer.phone
        }
      end
    end

    # recharge via OM
    # @return [Object]
    def rechargeSprintPay
      # phone         = params[:phone].to_i
      token         = params[:token] #request.headers['HTTP_X_API_POP_KEY']
      @phone        = params[:phone]
      amount        = params[:amount].to_i
      network_name  = params[:network_name]

      #on verifie l'existance de cet utilisateur
      customer = Customer.find_by_authentication_token(token)
      if customer.blank?
        render json: {
          status:   :not_found,
          message:  "Customer not found"
        }
      else
        # on effectuer le transfert via SP en se basant sur le network name
        if network_name == "ORANGE"

          SprintPay::Pay::Payment.new(@phone, amount)
          result = SprintPay::Pay::Payment.orange

          # recuperation et application du callBack
          if result["statusDesc"] == "FAILURE"
            # echec de la transaction
            render json: {
              status:   result["statusDesc"],
              message:  result["description"],
              code:     result["statusCode"],
              motif:    result["motif"]
            }
          else
            # tout de passe bien

            # on recupere le compte de l'utilisateur courant
            account = Account.find_by_customer_id(customer.id)
            if account.blank?
              render json: {
                status:   :not_found,
                message:  "Compte inconnu"
              }
            else
              # le compte existe, on peut continuer le traitement
              pp_amount = result["amount"]

              account.amount += pp_amount

              # on met a jour le compte du customer du noveau montant recu
              if account.update(amount: account.amount)
                render json: {
                  status:   :success,
                  message:  "Votre compte POPCASH a ete credité d'un montant de #{result["amount"]}"
                }
              else
                render json:
                {
                  status:   :failed,
                  message:  "Impossible de mettre a jour votre compte"
                  #Lancer le processus de  rollBack de montant precedement debité
                }
              end
            end
          end
        elsif network_name == "MTN"

          # Paiement par MTN MOMO

          SprintPay::Pay::Payment.new(@phone, amount)
          result = SprintPay::Pay::Payment.mtn

          # recuperation et application du callBack
          if result["statusDesc"] == "FAILURE"
            # echec de la transaction
            render json: {
              status:   result["statusDesc"],
              message:  result["description"],
              code:     result["statusCode"],
              motif:    result["motif"]
            }
          else
            # tout de passe bien

            # on recupere le compte de l'utilisateur courant
            account = Account.find_by_customer_id(customer.id)
            if account.blank?
              render json: {
                status:   :not_found,
                message:  "Compte inconnu"
              }
            else
              # le compte existe, on peut continuer le traitement
              pp_amount = result["amount"]

              account.amount += pp_amount

              # on met a jour le compte du customer du noveau montant recu
              if account.update(amount: account.amount)
                render json: {
                  status:   :success,
                  message:  "Votre compte POPCASH a ete credité d'un montant de #{result["amount"]}"
                }
              else
                render json:
                {
                  status:   :failed,
                  message:  "Impossible de mettre a jour votre compte"
                  #Lancer le processus de  rollBack de montant precedement debité
                }
              end
            end
          end
        end
      end
    end

    # gestion des transaction

    private

    def account_params
        params.require(:customer).permit(:name, :second_name, :cni, :phone)
    end

end