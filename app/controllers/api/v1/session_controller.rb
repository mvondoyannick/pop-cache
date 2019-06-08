class Api::V1::SessionController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:signup, :signin, :validate_retrait, :signup_authentication, :service, :check_retrait, :histo, :retrivePassword, :resetPassword, :rechargeSprintPay, :getPhoneNumber, :getSpData, :updateAccount, :updatePassword, :testNetwork]

    #creation de compte utilisateur
    # @return [Object]
    def signup
      @ip     = request.remote_ip
      query = Client::signup(params[:nom], params[:second_name], params[:phone], params[:cni], params[:password], params[:sexe], params[:question_id], params[:reponse], params[:lat], params[:lon])
      render json: {
        status: query
      }
    end


    def get_balance
        phone       = params[:phone]
        password    = params[:password]
        @playerId   = params[:playerId]

        balance = Client::get_balance(phone, password, @playerId)
        render json: balance
    end

    def histo #retourn l'historique sur la base du telephone
      @customer = Customer.find_by_authentication_token(request.headers['HTTP_X_API_POP_KEY'])
      if @customer.blank?
        render json: {
            status:   :customer_not_found,
            message:  "utilisateur inconnu"
        }
      else
        render json: {
            message: Transaction.where(customer: @customer.id).order(created_at: :asc).last(10).reverse_order.as_json(only: [:date, :amount, :flag, :code, :color])
        }
      end
    end

    #Detail de l'historiqueAnswer.all
    def histoDetail
      @code_transaction   = params[:transaction]
      detail = Transaction.where(code: @code_transaction)
      if detail.blank?
        render json: {
            message:  "Aucune activité correspondante"
        }
      elsif detail.count == 2
        render json: {
            data:     detail
        }
      elsif detail.count > 2
        render json: {
            message:    "Impossible de retourner l'activite"
        }
      else
        render json: {
            message:    "Une erreur est survenue"
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
      @token      = params[:customer]
      @pwd        = params[:password]
      @playerId   = params[:playerId]

      #recherche du phone
      @customer = Customer.find_by_authentification_token(@token).phone
      if customer.blank?
        render json: {
          message: "Utilisateur inconnu sur la plateforme"
        }
      else
        @balance = Client::get_balance(@customer, @pwd, @playerId)
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
      @phone    = params[:customer]
      @pwd      = params[:password]
      @playerId = params[:oneSignalID]

      #verificatin du customer
      @customer = Customer.find_by_authentication_token(@phone)
      if @customer.blank?
        render json: {
            status:   404,
            flag:     :customer_not_found,
            message:  "Utilisateur inconnu"
        }
      else
        balance = Client::get_balance(@customer.phone, @pwd)
        if balance[0] == true
          render json: {
            status:   200,
            flag:     :success,
            message:  balance #balance[1]
          }
        else
          render json: {
            status:   404,
            flag:     :errors,
            message:  balance
          }
        end
      end
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
      phone     = params[:phone]
      code      = params[:code]
      @playerId = params[:playerId]

      authenticate = Parametre::Authentication::validate_2fa(phone, code, @playerId)
      if authenticate[0]
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
                Sms.new(customer.phone, "Votre mot de passe vient d etre mis a jour si vous n en etes pas l auteur, veillez vous rapprocher d un agence partenaire. PAYQUICK")
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

    #IDENTIFICATION DES DONN2ES DE RECHARGES RECU PAR LE CLIENT
    # @return [Object]
    def getSpData
      @token    = params[:token]
      @phone    = params[:phone]
      @amount   = params[:amount]

      #on recherche l'utilisateur
      @customer = Customer.find_by_authentication_token(@token)
      if @customer.blank?
        render json: {
          status:   404,
          flag:     :customer_not_found,
          message:  "Utilisateur inconnu"
        }
      else
      @status = Parametre::PersonalData::numeroOperateurMobile(@phone)
      if @status == "orange"
        #on formate la nouvelle image
        render json: {
          status:         200,
          flag:           :success,
          phone:          @phone,
          amount:         @amount.to_i,
          network:        @status,
          operator:       "ORANGE MONEY",
          amount_total:   Parametre::Parametre::agis_percentage(@amount),
          logo:           "#{request.base_url}#{ActionController::Base.helpers.asset_path("orange.png")}"
        }
        elsif @status == "mtn"
          render json: {
            status:       200,
            flag:         :success,
            phone:        @phone,
            amount:       @amount.to_i,
            network:      @status,
            operator:     "MOBILE MONEY",
            amount_total: Parametre::Parametre::agis_percentage(@amount),
            logo:         "#{request.base_url}#{ActionController::Base.helpers.asset_path("mtn.jpg")}"
          }
        elsif @status == "nexttel"
          render json: {
            status:       404,
            flag:         :failed,
            network:      @status,
            operator:     "NEXTTEL POSSA",
            message:      "NEXTTEL POSSA PAS ENCORE SUPPORTE",
            logo:         "#{request.base_url}#{ActionController::Base.helpers.asset_path("nexttel-possa.png")}"
          }
        else
          render json: {
            status:   404,
            flag:     :failed,
            message:  "OPERATEUR NON SUPPORTE"
          }
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
          status: :not_found,
          message: "Utilisateur inconnu"
        }
      else
        render json: {
          status: :found,
          message: @customer.phone
        }
      end
    end


    #Mettre a jour son mot de passe
    def updatePassword
      Rails::logger::info "Starting caal method for renewing password"
      @token          = request.headers["HTTP_X_API_POP_KEY"]
      @previouPwd     = params[:hold_pass].to_i
      @newPwd         = params[:new_pass]

      #on recherch le client sur la base de son token
      @customer = Customer.find_by_authentication_token(@token)
      if @customer.blank?
        Rails::logger::info "User is unknow"
        render json: {
            status:     404,
            flag:       :cunstomer_not_found,
            message:    "Utilisateur inconnu"
        }
      else
        #tout va bien on verifie que c'est bien le @previeouPwd
        if @customer.valid_password?(@previouPwd)
          Rails::logger::info "User is valid"
          #tout va bien, on peut continuer en chageant les informations sur le mot de passe
            @customer.update(password: @newPwd)
            #on notifie le gar que tout c'est bien passé
            #Notification SMS
            Sms.new(@customer.phone, "Votre mot de passe a ete mis a jour. PAYQUICK")
            Sms::send

            render json: {
              status:     200,
              flag:       :password_updated,
              message:    "Votre mot de passe a ete mis a jour. Merci de vous reconnecter a PAYQUICK"
            }
        else
          Rails::logger::info "User is invalid"
          render json: {
            status:     404,
            flag:       :password_no_match,
            message:    "Impossible de vous identifier"
          }
        end
      end
    end

    # recharge via OM
    # @return [Object]
    def rechargeSprintPay
      # phone         = params[:phone].to_i
      token         = params[:token] #request.headers['HTTP_X_API_POP_KEY']
      @phone        = params[:phone]
      amount        = params[:amount].to_i
      network_name  = params[:network_name].upcase

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
              pp_amount = result["amount"].to_f

              account.amount += pp_amount

              # on met a jour le compte du customer du noveau montant recu
              if account.update(amount: account.amount)
                if Parametre::PersonalData.getHistorique(customer.id, @hash, amount, "RECHARGE VIA #{network_name.upcase}") == true
                  Sms.new(customer.phone, "Recharge de votre compte d'un montant de #{amount} F CFA depuis #{network_name}. Nouveau solde : #{account.amount} F CFA")
                  Sms::send
                  render json: {
                      status:   :success,
                      message:  "Votre compte POPCASH a ete credité d'un montant de #{result["amount"]} depuis #{network_name}"
                  }
                else
                  render json: {
                    status:   :failed,
                    message:  "Impossible de recharger votre compte PAYQUICK d'un montant de #{result["amount"]} depuis #{network_name} => erreurs : #{result}"
                  }
                end

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
                if Parametre::PersonalData.getHistorique(customer.id, @hash, amount, "RECHARGE VIA #{network_name.upcase}") == true
                  Sms.new(customer.phone, "Recharge de votre compte d'un montant de #{amount} F CFA depuis #{network_name}. Nouveau solde : #{account.amount} F CFA")
                  Sms::send
                  render json: {
                    status:   :success,
                    message:  "Votre compte POPCASH a ete credité d'un montant de #{result["amount"]} depuis #{network_name}"
                  }
                else
                  render json: {
                    status:   :failed,
                    message:  "Impossible de recharger votre compte PAYQUICK d'un montant de #{result["amount"]} depuis #{network_name} : Erreurs : #{result}"
                  }
                end
              else
                render json:
                {
                  status:   :failed,
                  message:  "Impossible de mettre a jour votre compte"
                }
              end
            end
          end
        elsif network_name == "NEXTTEL"
          render json: {
              status:   :failed,
              message:  "Pas encore supporté"
          }
        end
      end
    end

    #verificatin d'un utilisateur et validation de son pwd
    def authorization
      @token    = params[:token]
      @pwd      = params[:password]

      #recherche du customer
      @customer = Customer.find_by_authentication_token(@token)
      if @customer.blank?
        render json: {
            status:   :failed,
            flag:     :customer_not_found,
            message:  "Utilisateur inconnu"
        }
      else
        if @customer.valid_password?(@pwd)
          render json: {
            status:   :success,
            flag:     :customer_found,
            message:  @customer.as_json(only: [:name, :second_name, :phone, :sexe, :cni])
          }
        else
          #head("unauthorize")
          render json: {
              status:   :failed,
              flag:     :customer_unauthorize,
              message:  "Numero de telephone ou mot de passe invalide"
          }
        end
      end
    end


    # Mise a jour des informations du compte utilisateur
    def updateAccount
      #@header       = request.headers['HTTP_X_API_POP_KEY']
      @token        = params[:token]
      @name         = params[:name]
      @second_name  = params[:second_name]
      @sexe         = params[:sexe]
      @password     = params[:password]
      puts "Mot de passe #{params[:token]}"

      @customer = Customer.find_by_authentication_token(@token)
      if @customer.blank?
        render json: {
            message: "Utilisateur Inconnu"
        }
      else
        if @password.present?
          if @customer.update(name: @name, second_name: @second_name, sexe: @sexe, password: @password)
            render json: {
                status:   :success,
                flag:     :data_updated,
                message:  "Profil mis a jour"
            }
          else
            render json: {
                status:   :failed,
                flag:     :data_not_updated,
                message: "Impossible de faire la mise a jour : #{@customer.errors.full_messages}"
            }
          end
        else
          # mise a jour du profile sans mot de passe
          if @customer.update(name: @name, second_name: @second_name, sexe: @sexe)
            render json: {
                status:   :success,
                flag:     :data_updated,
                message: "Profil personnel et mote de passe mis a jour"
            }
          else
            render json: {
                status:   :failed,
                flag:     :data_not_updated,
                message: "Impossible de faire la mise a jour : #{@customer.errors.full_messages}"
            }
          end
        end
      end
    end

    #test de la connxino internet
    def testNetwork
      render json: true
    end


    #Verifier si un telephone appartient a la plateforme
    def checkPhone
      @phone  = params[:phone]

      #on demarre les recherches
      @customer = Customer.find_by_phone(@phone)
      if @customer.blank?
        render json: {
          status:   404,
          flag:     :false,
          message:  "Numeron inconnu",
          data:     nil
        }
      else
        # le telephone a été trouvé sur la plateforme
        @answer = Answer.find_by_customer_id(@customer.id)
        if @answer.blank?
          render json: {
              status:  404,
              flag:   :false,
              message: "Aucune question trouvée pour cet utilisateur",
              data: nil
          }
        else
          #on retourne la question trouvé dans answer
          render json: {
            status:     200,
            flag:       :question_found,
            message:    "Question trouvée",
            question:   Question.find(@answer.question_id).content,
            question_id: Question.find(@answer.question_id).id
          }
        end
      end
    end

    # gestion des transaction

    private

    def account_params
        params.require(:customer).permit(:name, :second_name, :cni, :phone)
    end

end