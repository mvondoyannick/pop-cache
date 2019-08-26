class Api::V1::SessionController < ApplicationController
    #skip_before_action :verify_authenticity_token, only: [:signup, :signin, :validate_retrait, :signup_authentication, :service, :check_retrait, :histo, :retrivePassword, :resetPassword, :rechargeSprintPay, :getPhoneNumber, :getSpData, :updateAccount, :updatePassword, :testNetwork]

    before_action :check_customer, except: [:signup, :signin, :checkPhone, :resetPassword, :retrivePassword, :authNewUuidDevice, :question, :signup_authentication, :rechargeSprintPay, :getSpData, :checkToken]
    #before_action :check_phone, except: [:signup, :signin, :checkPhone, :resetPassword, :retrivePassword, :authNewUuidDevice]

    #CREATE CUSTOMER ACCOUNTpassword 
    # @return [Object]
    def signup
      @ip             = request.remote_ip
      @name           = params[:nom]
      @second_name    = params[:second_name]
      @tel            = params[:phone]
      #@cni            = params[:cni]
      @password       = params[:password]
      @sexe           = params[:sexe]
      @question_id    = params[:question_id]
      @response       = params[:reponse]

      #adding locale I18n
      @locale         = "en" #request.headers["HTTP_LOCALE"]

      #données elementaire de base
      if @tel.present? && @question_id.present? && @response.present? && @password.present? && @name.present? && @ip.present? && @sexe.present?

        query = Client::signup({name: @name, second_name: @second_name, phone: @tel, password: @password, sexe: @sexe, question: @question_id, answer: @response, ip: @ip}, "create customer account", @locale[0..1])
        render json: {
          status: query
        }

      else

        render json: {
          satus: :false,
          message: I18n.t("DataNotComplete", locale: @locale[0..1]) #"Centaines informations sont manquantes"
        }

      end

    end



    #CHECK WEB
    def checkToken
      data = Base64.strict_decode64(params[:qrcode])
      qrcode = data.split("@")
      customer = Customer.find_by_authentication_token(qrcode[0])
      if customer.blank?
        render json: {
          status: false,
          message: "Utilisateur inconnu"
        }
      else
        # send SMS
        Sms.sender(customer.phone, "Merci de confirmer ce payment en entrant votre mot de passe dans la section <RECEVOIR UN PAIEMENT> de l'application PayMeQuick")
        render json: {
          status: true,
          message: "#{Client.prettyCallSexe(customer.sexe)} #{customer.complete_name} ouvrez l'application PayMeQuick et confirmer le paiement"
        }
    end
  end


    #CUSTOMER ACCOUNT BALANCE
    def get_balance
      phone       = params[:phone]
      password    = params[:password]
      @playerId   = params[:playerId]

      balance = Client::get_balance(phone, password)
      render json: balance
    end

    #CUSTOMER HISTORY
    # DEPRECATED
    # TODO Remove this method on next release, deprecatd since 0.1.2
    def histo #retourn l'historique sur la base du telephone
      @customer = Customer.find_by_authentication_token(request.headers['HTTP_X_API_POP_KEY'])
      if @customer.blank?
        render json: {
          status:   :customer_not_found,
          message:  "utilisateur inconnu"
        }
      else
        render json: {
          message: Transaction.where(customer: @customer.id).order(created_at: :desc).last(50).reverse.as_json(only: [:date, :amount, :flag, :code, :color, :region])
        }
      end
    end


     #retourne les informations de la semaine entre le début de la semaine et la fin de la semaine
     # Refactoring
    def history
      @token = request.headers['HTTP_X_API_POP_KEY'] #Get the customer header
      @locale = "en" #request.headers["HTTP_LOCALE"] # Get client locale lang between en and fr
      @ip_adresse = request.remote_ip # Get customer remote IP
      Rails::logger::info "receive token : #{@token} from #{@ip_adresse}"
      @period   = params[:period]
      if @token.present?

        #Search and identify customer token
        customer = Customer.find_by_authentication_token(@token)
        if customer.blank?

          render json: {
            status: false,
            message: "CUSTOMER NOT FOUND"
          }

        else

          #starting get customer history
          request = Logstory::Histo.h_customer(@token, @period, @locale[0..1])
          render json: {
            status: request[0],
            message: request[1]
          }

        end

      else

        render json: {
            status:   false,
            message:  I18n.t("customerNotFound", locale: @locale[0..1])
        }

      end
    end



    #CUSTOMER PERIOD HISTORY
    # Permet de retourner le'historique en fonction d'une periode bien precise
    def historyByDate
      @token    = request.headers['HTTP_X_API_POP_KEY']
      @locate   = "en" #request.headers["HTTP_LOCALE"]
      @debut    = params[:begin]
      @fin      = params[:end]

      if @debut.present? && @fin.present?
        if @debut == @fin
          render json: {
            status: false,
            message: I18n.t("sameDate", locale: @locale) #"Les dates sont identiques!"
          }
        else
          periode = Logstory::Histo.h_interval({token: @token, begin: @debut, end: @fin}, @locale[0..1])
          render json: {
              status:   periode[0],
              message:  periode[1]
          }
        end
      end
    end



    #CUSTOMER ALL HISTORY SINCE BEGINING
    # Detail de l'historiqueAnswer.all
    # TODO deprecated, remove this method on next release
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

    #RENDER QUESTIONS
    # gestion des questions de securité
    # retourne toutes les question de securité  dispnible sur la plateforme
    def question
      question = Question.all
      render json: {
        message: question.as_json(only: [:id, :content])
      }
    end


    #RENDER CATEGORIES
    def serviceCategorie
      categorie = Cat.order(name: :asc)
      render json: {
          categories: categorie
      }
    end

    #RENDER CATEGORIES DETAILS
    def detailCategorie
      id = params[:id]
      detailCat = Cat.where(cat_id: id, name: :asc)
      render json: {
          cat_detail: detailCat
      }
    end

    #RENDER SERVICE FROM CATEGORIES
    def service

      id = params[:id]
      services = Service.where(cat_id: id)
      render json: {
          services: services
      }

    end


    #RENDER HISTORY
    # @deprecated
    def p
      phone = params[:phone]
      query = History::History::payment(phone)
      render json: {
          message: query
      }
    end

    

    #AUTHENTICATE CUSTOMER
    def signin
      Rails::logger.info "Starting signin process ..."
      phone = params[:phone]
      password = params[:password]
      device = params[:uuid]
      locale = "en" #request.headers["HTTP_LOCALE"]

      if phone.present? && password.present?

        #query the user
        signin = Client::signin({phone: phone, password: password, device: device}, locale[0..1], "Authentification")
        puts "Login data response : #{signin}"
        render json: signin

      else

        render json: {
            status: :missing_parameters,
            message: "PARAMETRES MANQUANT"
        }

      end
    end


    # Update customer device uuis
    def authNewUuidDevice
      @phone = params[:phone]
      @sms = params[:code]
      @uuid = params[:uuid]

      Rails::logger::info "Starting adding new uuid devices #{@uuid}"
      query = Client::updateDevice(uuid: @uuid, phone: @phone, sms: @sms)
      render json: {
        status: query[0],
        message: query[1],
      }
      
    end

    #obtention du solde du compte client
    def solde
      @token      = params[:customer]
      @pwd        = params[:password]
      @playerId   = params[:playerId]
      locale = "en" #request.headers["HTTP_LOCALE"]

      #check all datas available
      if @token.present? && @pwd.present? && @playerId.present?

        #recherche du phone
        @customer = Customer.find_by_authentification_token(@token)
        if customer.blank?
          render json: {
              message: "Utilisateur inconnu sur la plateforme"
          }
        else
          @customer = Client::get_balance({phone: @customer, password: @pwd}, locale[0..1])
          if balance
            render json: {
                message: @customer
            }
          else
            render json: {
                message: "compte vide"
            }
          end
        end

      else

        render json: {
            status:   false,
            message:  "Certaines informations sont manquantes"
        }

      end


    end

    def getSoldeCustomer
      @phone    = params[:customer]
      @pwd      = params[:password]
      @playerId = params[:oneSignalID]
      locale = "en" #request.headers["HTTP_LOCALE"]

      #verificatin du customer
      @customer = Customer.find_by_authentication_token(@phone)
      if @customer.blank?
        render json: {
          status:   404,
          flag:     :customer_not_found,
          message:  "Utilisateur inconnu"
        }
      else
        balance = Client::get_balance({phone: @customer.phone, password: @pwd}, "Obtention crédit compte client", locale[0..1])
        if balance[0]
          render json: {
            status:   200,
            flag:     :success,
            message:  balance[1]
          }
        else
          render json: {
            status:   404,
            flag:     :errors,
            message:  balance[1]
          }
        end
      end
    end

    #CHECK CUSTOMER INTENT RETRAIT
    # verification du retrait
    def check_retrait
        header = request.headers['HTTP_X_API_POP_KEY']
        locale = "en" #request.headers["HTTP_LOCALE"]
        begin
          render json: {
            status: Client::check_retrait_refactoring(header, locale[0..1])
          }
        rescue => exception
          render json: {
            error: exception
          }
        end
    end

    #CANCEL CUSTOMER INTENT RETRAIT
    # permet d'annuler le retrait en cours
    def cancel_retrait
      token = request.headers['HTTP_X_API_POP_KEY']
      locale = "en" #request.headers['HTTP_LOCALE']
      begin
        cancel = Client.cancelRetrait({token: token}, "Annulation de la procedure de retrait", locale[0..1])
        render json: {
            message: cancel
        }
      rescue => exception
        render json: {
            error: exception
        }
      end

    end

    #VALIDATE CUSTOMER INTENT RETRAIT
    def validate_retrait
        password = Base64.decode64(params[:password])
        
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

    #VALIDATE SIGNUP SMS AUTHENTICATION WITH ONE TIME PASSWORD
    # validation de 2FA
    def signup_authentication
      phone     = params[:phone]
      code      = params[:code]
      @playerId = params[:playerId]

      authenticate = Parametre::Authentication::validate_otp(phone, code, @playerId)
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


    #RECUPERATION DU CUSTOMER PASSWORD
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

    #RESET CUSTOMER PASSWORD
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

      #reduction des requetes inutiles
      if @token.present? && @phone.present? && @amount.present?

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
          elsif @status == false || @status == inconnu
            render json: {
                status:   404,
                flag:     :failed,
                message:  "OPERATEUR NON SUPPORTE"
            }
          end
        end

      else

        render json: {
            status: 404,
            flag:   :failed,
            message: "Informations incorrectes"
        }

      end
    end

    #mise en oeuvre du virtual SprintPayLocalAPI
    def virtualSP
      @token = params[:token]
      @phone = params[:phone]
      @amount = params[:amount]
      network_name = params[:network_name]

      puts "Vistual SP activated ..."
      render json: SprintPay::Pay::Payment.sp(@token, @phone, @amount, network_name)
    end

    #RENDER CUSTOMER PHONE WITH HEADER
    # @deprecated
    def getPhoneNumber
      header = request.headers['HTTP_X_API_POP_KEY']

      if header.present?

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

      else

        render json: {
            status: :unprocessable_entity,
            message: "Certaines informations sont manquantes"
        }

      end

    end


    #UPDATE CUSTOMER PASSWORD ACCOUNT
    # Mettre a jour son mot de passe
    def updatePassword
      Rails::logger::info "Starting caal method for renewing password"
      @token          = request.headers["HTTP_X_API_POP_KEY"]
      @previouPwd     = params[:hold_pass] # Ancien mot de passe
      @newPwd         = params[:new_pass] # Nouveau mot de passe

      if @token.present? && @previouPwd.present? && @newPwd.present?

        #on recherch le client sur la base de son token
        @customer = Customer.find_by_authentication_token(@token)
        if @customer.blank?
          Rails::logger::info "User is unknow"
          render json: {
              status:     false,
              flag:       :cunstomer_not_found,
              message:    "Utilisateur inconnu"
          }
        else
          #tout va bien on verifie que c'est bien le @previeouPwd
          if @customer.valid_password?(@previouPwd)
            Rails::logger::info "User is valid"
            #tout va bien, on peut continuer en chageant les informations sur le mot de passe
            if @customer.update(password: @newPwd, authentication_token: nil)

              #on notifie le gar que tout c'est bien passé
              #Notification SMS
              Sms.sender(@customer.phone, "Votre mot de passe a ete mis a jour, merci de vous reconnecter. PayMeQuick")

              render json: {
                status: true,
                flag: :password_updated,
                message: "Votre mot de passe a ete mis a jour. Merci de vous reconnecter a PayMeQuick"
              }

            else
              Rails::logger.info "Failed to update password"
              render json: {
                status: false,
                flag: :password_not_updated,
                message: "Impossible de mettre à jour votre mot de passe"
              }

            end
          else
            Rails::logger::info "User is invalid"
            render json: {
              status:     404,
              flag:       :password_no_match,
              message:    "Impossible de vous identifier"
            }
          end
        end

      else

        render json: {
          status: false,
          flag:   "Some parametres are misssing",
          message: "Données invalides ou manquantes",
          params: "#{@token}, #{@previouPwd}, #{@newPwd}"
        }

      end

    end

    #CREDIT PMQ WITH ORANGE MONEY | SPRINTPAY API
    # @return [Object]
    def rechargeSprintPay
      # phone         = params[:phone].to_i
      token         = request.headers['HTTP_X_API_POP_KEY']
      @phone        = params[:phone]
      amount        = params[:amount].to_i
      network_name  = params[:network_name].upcase
      @ip = request.remote_ip

      #on verifie l'existance de cet utilisateur
      customer = Customer.find_by_authentication_token(token)
      if customer.blank?
        render json: {
          status:   :not_found,
          message:  "Customer not found"
        }
      else
        # on effectuer le transfert via SP en se basant sur le network name
        case network_name
        when "ORANGE"
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
            account = customer.account #Account.find_by_customer_id(customer.id)
            if account.blank?
              render json: {
                  status:   :not_found,
                  message:  "Compte inconnu ou inexistant"
              }
            else
              # le compte existe, on peut continuer le traitement
              pp_amount = result["amount"].to_f

              account.amount += pp_amount

              # on met a jour le compte du customer du noveau montant recu
              if account.update(amount: account.amount)

                # Ecriture de l'historique

                h = History.new(
                    customer_id: customer.id,
                    amount: amount,
                    code: @hash,
                    flag: "recharge".upcase,
                    context: "Mobile".upcase,
                    ip: @ip
                )
                if h.save #Parametre::PersonalData.getHistorique(customer.id, @hash, amount, "RECHARGE VIA #{network_name.upcase}") == true
                  Sms.sender(customer.phone, "Recharge de votre compte d'un montant de #{amount} F CFA depuis #{network_name}. Nouveau solde : #{account.amount} F CFA")

                  render json: {
                      status:   :success,
                      message:  "Votre compte PayMeQuick a ete credité d'un montant de #{result["amount"]} depuis #{network_name}"
                  }
                else
                  render json: {
                      status:   :failed,
                      message:  "Impossible de recharger votre compte PayMeQuick d'un montant de #{result["amount"]} depuis #{network_name} => erreurs : #{result}"
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
        when "MTN"
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
            account = customer.account #Account.find_by_customer_id(customer.id)
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
                h = History.new(
                    customer_id: customer.id,
                    amount: amount,
                    code: @hash,
                    flag: "recharge".upcase,
                    context: "Mobile".upcase,
                    ip: @ip
                )
                if h.save #Parametre::PersonalData.getHistorique(customer.id, @hash, amount, "RECHARGE VIA #{network_name.upcase}") == true
                  Sms.sender(customer.phone, "Recharge de votre compte d'un montant de #{amount} F CFA depuis #{network_name}. Nouveau solde : #{account.amount} F CFA")

                  render json: {
                      status:   :success,
                      message:  "Votre compte PayMeQuick a ete credité d'un montant de #{result["amount"]} depuis #{network_name}"
                  }
                else
                  render json: {
                      status:   :failed,
                      message:  "Impossible de recharger votre compte PayMeQuick d'un montant de #{result["amount"]} depuis #{network_name} : Erreurs : #{result}"
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
        when "NEXTTEL"
          render json: {
              status:   :failed,
              message:  "Pas encore supporté"
          }
        else
          render json: {
              status:   :failed,
              message:  "Opérateur pas encore supporté"
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
      #ApiMailer.sendAdmin("lorem").deliver_now!
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

    def check_customer
      @token = request.headers["HTTP_X_API_POP_KEY"]
      @uuid = request.headers["HTTP_UUID"]

      puts "recherche de la langue"
      @language = "en"#request.headers["HTTP_LOCALE"]

      puts "La langue recu est #{@language}"

      puts "Header data receive : Token #{@token}, UUID : #{@uuid}"

      begin
        customer = Customer.find_by(authentication_token: @token, two_fa: 'authenticate')
        if customer.blank?
          #response.set_header('HEADER NAME', :unauthorized)
          render json: {
              message: "Vous n'etes pas autorisé à acceder à ce service."
          },
          status: :unauthorized
          #head :unauthorized
        end
      rescue ActiveRecord::RecordNotFound
        render json: {
            status: false,
            message: "Utilisateur inconnu"
        },
        status: :unprocessable_entity
      end

    end

    def check_signature
      signature = request.headers[:HTTP_SIGNATURE]

      begin
      #check if signature is valid
      valid_signature = JWT.decode

      rescue => exception
        render json: {
            status: false,
            message: ""
        },
        status: :unauthorized

      end

    end

    # Search customer data integrity
    # only valide if customer data and md5(data) are the same
    # return 401 header if failed
    def check_integrity
      integrity = params[:integrity]

    end
end