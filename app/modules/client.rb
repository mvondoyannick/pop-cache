class Client
  $signature = "POP-CASH"
  $limit_amount = 150000
  $limit_day_transaction = 100
  $devise = "F CFA"
  $status = {
    false: :false
  }

  require 'securerandom'

    def initialize(from, to, amount, pwd)
      $from = from
      $to = to 
      $amount = amount 
      $pwd = pwd
    end

    def self.create_user(name, prenom, phone, cni, password, sexe)
      @name = name
      @prenom = prenom
      @phone = phone
      @cni = cni
      @email = "#{@phone.to_i}@pop-cash.cm"
      @password = password
      @sexe = sexe

      Rails::logger::info {"Données recu dans l'environnement #{@name} | #{@prenom} | #{@phone} | #{@password} | #{@cni} avec succes."}

      #creation du compte de l'utilisateur
      customer = Customer.new(
        name: @name,
        second_name: @prenom,
        phone: @phone,
        email: @email,
        password: @password,
        type_id: 1,
        cni: @cni,
        sexe: @sexe
      )

      if customer.save
        Rails::logger::info {"Creation de de l'utiliateur #{@phone} avec succes."}
        account = create_user_account(customer.id, customer.phone)
        if account[0] == true
          #generation de 2Fa
          auth = Parametre::Authentication::auth_two_factor(@phone, 'context')
          if auth[0] == true
            return true, @phone
          else
            return auth[1]
          end
        else
          Rails::logger::info "Impossible de creer le compte du client #{@phone}"
          return false, "Impossible de creer le compte client"
        end
      else
        Rails::logger::info {"Creation de de l'utiliateur #{@phone} impossible : #{customer.errors.full_messages}"}
        return false, "Echec de creation du profil personnel. code erreurs : #{customer.errors.full_messages}"
      end
    end

    #creation du compte utilisateur
    def self.create_user_account(id, phone)
      Rails::logger::info "Demarrage de la creation du compte utilisateur ..."
      @id = id
      @phone = phone
      customer_account = Account.new(
        amount: 5000,
        customer_id: @id
      )
      
      if customer_account.save
        Rails::logger::info "Utilisateur #{@phone} crée a #{Time.now}"
        Sms.new(@phone, "#{@phone} Bienvenue chez POP CASH, votre porte monnaie virtuel vient d\'etre cree, il dispose d\'une somme de 5000 #{$devise}. #{$signature}")
        Sms::send
        return true,"creation porte-monnaie succes"
      else
        Sms.new(@phone, "Impossible de creer Votre porte-monnaie virtuel, merci de vous rappocher d\'un service Express Union. #{$signature}")
        Sms::send
        return false, "Creation porte-monnaie failed"
      end
    end


    #permet de crediter le compte utilisateur en se basant sur son numero de telephone et sur le montant
    def self.credit_account(phone, amount)
      @phone = phone
      @amount = amount

      #on rechercher le user pour avoir sont ID
      customer = Customer.where(phone: @phone).first
      if customer.blank?
        return false, "Aucune utilisateur ne correspond."
      else
          customer_account = Account.where(customer_id: customer.id).first
          if customer_account.blank?
            return false, "Auccun compte correspondant trouve."
          else
            customer_account.amount = customer_account.amount.to_i + @amount.to_i
            if customer_account.save
              hash = SecureRandom.hex(13).upcase
              #Sms.new(@phone, "Mr/Mme #{customer.name} #{customer.second_name}, votre compte a ete cree et vous avez ete crediter d'un montant de #{@amount} #{$devise}, le solde de votre compte est de #{customer_account.amount} #{$devise}. ID Transaction : #{hash}. #{$signature}")
              Sms.new(@phone, "Mr/Mme #{customer.name} #{customer.second_name}, votre compte crediter d'un montant de #{@amount} #{$devise}, le solde de votre compte est de #{customer_account.amount} #{$devise}. ID Transaction : #{hash}. #{$signature}")
              Sms::send
              return "Le compte a ete credite d\'un montant de #{@amount}'."
            else
              Sms.new(@phone, "Mr/Mme #{customer.name} #{customer.second_name}, impossible de crediter votre compte. Echec de la Transaction #{hash}. #{$signature}")
              Sms::send
              return "impossible de crediter le compte. code erreurs : #{customer_account.errors}"
            end
          end  
      end
  end


  #permet de verifier le token de l'utilisateur
  # @method     Verifier le token d'un utilisateur
  # @name       Client::userTokenAuthenticate
  # @params     token
  # @output     boolean [true/false]
  def self.userTokenAuthenticate(token)
    @token = token
    Rails::logger::info "Starting user token verification"

    #on recherche le gar en question en decodant la chaine
    query = JWT.decode token, Rails,application.secrets.secret_key_base
    puts query
  end

    #authentication of user who have account on the plateforme
    # @method     Authentifier un utilisateur
    # @name       Client::auth_user
    # @params     phone, password
    # @output     boolean [true/false]
    def self.auth_user(phone, password)
      @phone = phone
      @password = password

      Rails::logger::info "Authenticating user #{@phone} call ..."

      customer = Customer.where(phone: @phone).first
      if !customer.blank?
        if customer.valid_password?(@password)
          if customer.two_fa == "authenticate"
            #on genere l'empreint/token de cet utilisateur sur la base de ses informations personnelles
            payload = {
              id: customer.id,
              expire: 14.days.from_now
            }

            authFinger = customer.id.to_s

            # on envoi cette information dans la table de l'utilisateur courant

            if customer.update(tokenauthentication: authFinger)
              Rails::logger::info "Token updated!"
              Rails::logger::info "Authentication success for #{phone}."
              return customer.as_json(only: [:name, :second_name, :tokenauthentication, :authentication_token, :apikey]), status: :created
            else
              Rails::logger::error "Impossible de mettre à jour le Token de l'utilisateur"
            end 

          else
            Rails::logger::info "Utilisateur non authentier"
            return false, "Utilisateur non authentifié sur POP CASH"
          end         
        else
          Rails::logger::error "Authenticating user failed, bad password. end request!"
          return false, "Impossible de vous identifier : Utilisateur/Mot de passe inconnu ou utilisateur non authentifé"
        end
      else
        Rails::logger::error "Authenticating user failled, unknow user. end request!"
        return false, "Utilisateur inconnu", status: :unauthorized
      end
    end

    def self.get_balance(tel, password)
      @phone = tel
      @password = password

      Rails::logger::info "#{@phone}++#{@password}"

      #on recherche le client
      query = Customer.find_by_phone(@phone)
      if query.blank?
        Rails::logger::error "Authenticating user failed, unknow user. end request!"
        return false, "Utilisateur inconnu."
      else
        if query.valid_password?(@password)
          account = Account.where(customer_id: query.id).first
          if account.blank?
            return false, "Aucun compte utilisateur correcpondant ou compte vide"
          else
            Sms.new(@phone, "Mr/Mme #{query.name} #{query.second_name}, le solde de votre compte est : #{account.amount} #{$devise}. #{$signature}")
            Sms::send
            return true,"Mr/Mme #{query.name} #{query.second_name}, le solde de votre compte est : #{account.amount} #{$devise}. #{$signature}"
          end
        else
          return false,  "Mot de passe invalide. #{$signature}"
        end
      end
    end


    #permet de mettre a jour le montant des comptes
    def self.update_account_client(id, amount)
        @id = id
        @amount = amount

        response = Account.find(@id)
        if !response.blank?
          response.amount = response.amount - @amount
          if response.save
            return true
          else
            return "failed"
          end
        else
          return false
        end
    end


    #permet de mettre a jour le montant des comptes marchand
    def self.update_account_marchand(id, amount)
        @id = id
        @amount = amount

        response = Account.find(@id)
        if !response.blank?
          response.amount = response.amount + @amount
          if response.save
            return true
          else
            return "failed"
          end
        else
          return false
        end
    end


    #recherche les informations sur l'emeteur de la requete de paiement
    def self.find_client(id)
      @sender_id = id
      query = Customer.find(id)
      if query.blank?
        return false, "Utilisateur inconnu"
      else
        return true, query
      end
    end

    #recherche les informations sur le receveur
    def self.find_marchand(id)
      @receiver_id = id
      query = Customer.find(id)
      if query.blank?
        Rails::logger::error "Impossible de terminer cette requete, utilisateur inconnu"
        return false, "Utilisateur inconnu"
      else
        Rails::logger::info "Utilisateur identifié"
        return true, query
      end
    end

    #pour debiter de l'argent dans le compte du client
    def debit_client(id, amount, signature)
      @id = id
      @amount = amount
      @signature = signature

      response = find_client(id)
      if response

      end
    end

    #debiter le compte utilisateur durant un retrait
    def self.debit_user_account(phone, amount)
      @phone = phone
      @amount = amount

      customer = Customer.where(phone: @phone).first
      if !customer.blank?
        account = Account.where(customer_id: customer.id).first
        if !account.blank?
          a = account.amount.to_i - @amount.to_i
          Rails::logger::info "Information compte client #{@phone} à #{Time.now} est de #{account.amount} F CFA."
          Rails::logger::info "Information compte client #{@phone} à avec le fameux A est de #{account.amount} F CFA."
          if account.update(customer_id: customer.id, amount: account.amount )
            Rails::logger::info "Compte debité avec succes"
            return true
          else
            Rails::logger::info "Impossible de mettre a jour les informations client"
            return false
          end
        end
      end
    end


    #pour les tests
    def self.err
      begin
        c = Customer.find(250)
      rescue => e #ActiveRecord::RecordNotFound
        Rails::logger::info "Impossible de trouver l'utilisateur : #{e}" 
      end
    end



    #validation du retrait par l'utilisateur/customer
    def self.validate_retrait(token, pwd)
      @token  = token
      @pwd    = pwd
      hash = "PR-#{SecureRandom.hex(13).upcase}"                    #ID de la transaction

      customer = Customer.find_by_authentication_token(@token)
      if customer && customer.valid_password?(@pwd)
        #on mets a jour les informations sur await sur customer
        await = Await.where(customer_id: customer.id).first
        if customer.update(await: nil)
          #on debit le compte le client
          debit_client = debit_user_account(customer.phone.to_s, await.amount)
          if debit_client && await.destroy
            Sms.new(customer.phone.to_s, "Vous venez de retirer #{await.amount} #{$devise} de votre compte. Votre solde est maintenant de #{Account.where(customer_id: customer.id).first.amount} F CFA. ID Transaction : #{hash}. #{$signature}")
            Sms::send
            #puts "Retrait effectué"
            Rails::logger::info "Retrait du montant #{await.amount} du compte effectué avec succes"
            return true, "Retrait de #{await.amount} #{$devise} effectué sur le compte #{customer.phone.to_s}. Votre solde est maintenant de #{Account.where(customer_id: customer.id).first.amount} F CFA. ID Transaction : #{hash} #{$signature}"
          else
            #puts "Impossible de retirer de l argent dans ce compte"
            Rails::logger::error "Impossible d'effectuer le Retrait du montant #{await.amount} du compte #{customer.phone.to_s}. Transaction annulée"
            return false, "retrait argent impossible. merci de contacter le service client au 007"
          end
        else
          #puts "Impossible de mettre a jour les informations utilisateur"
          Rails::logger::error "Impossible d'effectuer le retrait du montant #{await.amount} du compte #{customer.phone.to_s}. serveur indisponible"
          return false, "Impossible de communiquer avec l IA d AGIS"
        end
      else
        #puts "Mot de passe invalide"
        Rails::logger::error "Mot de passe invalide pour ce compte. transaction annulée"
        return false, "Mot de passe invalide"
      end
    end

    #pemet de verifier qu'un await est perimé ou pas
    # @ùethod     name Verifier sur une procedure de retrait est encore valide
    # @name       Client::is_await_valide
    # @params     phone
    # @output     boolean [true/false]
    def self.is_await_valid?(phone)
      @phone = phone
      Rails::logger::info "Starting await verification ..."
      customer = Customer.where(phone: phone).first
      if customer.blank?
        Rails::logger::error "Utilisateur #{@phone} est inconnu du systeme"
        return false, "Utilisateur inconnu"
      else
        await = Await.where(customer_id: customer.id).last
        if await.blank?
          Rails::logger::error "Aucun retrait en attente pour l'Utilisateur #{@phone}"
          return false, "Aucun retrait en attente pour l'Utilisateur #{@phone}"
        else
          #on comparate les dates
          if await.end >= Time.now && await.used == false
            Rails::logger::info "Transacttion #{await.hashawait} est en cours et valide."
            return true, "Transaction #{await.hashawait} valide"
          else
            Rails::logger::error "Transaction #{await.hashawait} n'est plus valide. supression..."
            if await.destroy
              Rails::logger::info "Transaction #{await.hashawait} qualifiée de perimée a été supprimée."
              return true, "Transaction #{await.hashawait} qualifiée de perimée a été supprimée."
            else
              Rails::logger::fatal "Transaction #{await.hashawait} qualifiée de perimée n'a pas pu etre supprimer. Impossible de supprimer la transaction. Contact du service de maintenance."
              contact = ContactForm.new(name: "MVONDO", email: "yaf.mvondo@agis-as.com", message: "FATAL : Transaction #{await.hashawait} qualifiée de perimée n'a pas pu etre supprimer. Intervention urgente.")
              contact.deliver
              return false, "Transaction #{await.hashawait} ne peut etre supprimer, demarrage de l'envoi du courriel au service de maintenance ..."
            end
          end
        end
      end
    end


    #permet d'annuler un retrait d'argent dans le compte client
    # @method   name Cancel current retrait by user
    # @name     Client::cancelRetrait
    # @params   phone, password, awaitHash
    # @output   boolean [true/false]
    def self.cancelRetrait(phone, pwd, hashawait)
      @phone = phone
      @pwd = pwd
      @hash = hashawait
      Rails::logger::info "Starting cancel retrait validation ..."
      customer = Customer.where(phone: @phone).first
      if !customer.blank? && customer.valid_password?(@pwd)
        Rails::logger::info "Utilisateur authentifié @ #{Time.now}"
        await = Await.where(customer_id: customer.id, hashawait: @hash).first
        if await.blank?
          Rails::logger::warn "Aucune transaction existante pour la transaction #{@hash}"
          return false, "Aucune transaction existante pour la transaction #{@hash}"
        else
          Rails::logger::info "Suppression de la transaction #{@hash} en cours ..."
          if await.destroy
            Rails::logger::info "Suppression du marqueur de retrait sur le customer"
            if customer.update(await: nil)
              Rails::logger::info "Suppression de la transaction #{@hash} terminées. annulation validée et terminée!"
              return true, "Transaction annulée!"
            else
              Rails::logger::error "Impossible de supprimer le marqueur de retrait de l'utillisateur"
              contact = ContactForm.new(name: "MVONDO", email: "yaf.mvondo@agis-as.com", message: "FATAL : Impossible de supprimer le marqueur de retrait  de la transaction #{await.hashawait} durant un processus d'annulation du client #{customer.phone}. Une erreur est survenue!")
              contact.deliver
              return false, "Impossible de supprimer le marqueur, une erreur est survenue"
            end
          else
            Rails::logger::error "La suppression de la transaction #{@hash}  a echouée. notification du service de maintenance"
            contact = ContactForm.new(name: "MVONDO", email: "yaf.mvondo@agis-as.com", message: "FATAL : Impossible de supprimer la transaction #{await.hashawait} durant un processus d'annulation du client #{customer.phone}. Une erreur est survenue!")
            contact.deliver
            return false, "Impossible de supprimer la transaction, contact du service de maintenance!"
          end
        end
      end
    end

    #permet de verifier qu'il ya un retrait en cours pour un numero de telephone/customer
    # @method   Check retrait | verifier le retrait
    # @name     Client::check_retrait
    # @params   phone
    # @output   boolean [true/false]
    def self.check_retrait(phone)
      @phone = phone
      customer = Customer.where(phone: phone).first
      if customer.blank?
        Rails::logger::info "Utilisateur inconnu"
        return false, "Utilisateur inconnu"
      else
        await = Await.where(customer_id: customer.id, id: customer.await).first
        if await.blank?
          Rails::logger::info "Aucun retrait trouvé pour ce compte"
          return false, "Aucun retrait sur votre compte  pour le moment"
        else
          Rails::logger::info "Existance d'un retrait pour ce compte"
          return true, await.as_json(only: :amount)
        end
      end
    end


    def self.check_retrait_refactoring(token)
      @token = token
      customer = Customer.where(authentication_token: @token).first
      if customer.blank?
        Rails::logger::info "Utilisateur inconnu"
        return false, "Utilisateur inconnu"
      else
        #on recherche le compte await du customer
        intent_retrait = Await.find_by_customer_id(customer.id)
        if intent_retrait.blank?
          Rails::logger::info "Aucun retrait pour cet utilisateur"
          return false, "Aucun retrait pour ce compte."
        else
          Rails::logger::info "Intent retrait trouvé"
          return true, intent_retrait.as_json(only: :amount)
        end
      end
    end

    #verifie le header du customer et returne true ou false en fonction des circonstance
    # @method name  Check Header for customer
    # @name         Client::checkHeader
    # @params       header 
    # @output       boolean [true/false]
    def self.checkHeader(header)
      @header = header
      header_customer = Customer.find_by_authentication_token(@header)
      if header_customer.blank?
        Rails::logger::info "Impossible d'authentifier le client"
        return false, "unauthenticable"
      else
        Rails::logger::info "Client authentifier"
        return true, header_customer.as_json(only: [:phone, :authentication_token])
      end
    end

    #permet de verifier si le client dispse suffisament d'argent dans son compte EU 
    # @method name  Get Balance before retrait
    # @name         Client::get_balance_retrait
    # @params       phone amount 
    # @output       boolean [true/false]
    def self.get_balance_retrait(phone, amount_retrait)
      @phone = phone
      @amount = amount_retrait.to_i
      Rails::logger::info "Starting get balance for account #{@phone}, amount of #{@amount}"
      #on ne peut pas retirer moins de 500 F CFA XAF
      if @amount < 500
        Rails::logger::warn "Tentative de retrait d'un montant inferieur a 500F, Transaction annulée"
        return false
      else
        customer = Customer.where(phone: @phone).first
        if customer.blank?
          Rails::logger::error "Utilisation inconnu, Transaction annulée."
          return false
        else
          customer_amount = Account.where(customer_id: customer.id).first.amount
          if customer_amount.to_i > @amount.to_i 
            Rails::logger::info "Montant superieur/egale dans le compte #{@phone}. Transaction possible."
            return true
          else
            Sms.new(@phone, "Le montant de votre compte est insuffisant. #{$signature}")
            Sms::send
            Rails::logger::warn "Montant inferieur dans le compte #{@phone}. Impossible de poursuivre la transaction."
            return false
          end
        end
      end
    end


    # permet d'initialiser une procedure de retrait du coté de l'agent EU 
    # @method name  Get Balance before retrait
    # @name         Client::init_retrait
    # @params       phone amount 
    # @output       boolean [true/false]
    def self.init_retrait(phone, amount)
      @phone = phone
      @amount = amount.to_i
      Rails::logger::info "Demarrage initialisation retrait pour #{@phone} ..."
      #se trouve dans la table retrait_await, on ajout un marqueur au client
      customer = Customer.where(phone: @phone).first
      if get_balance_retrait(@phone, @amount) == true #il a suffisament d'argent
        if customer.await.nil?
          #on creet un nouvel await
          await = Await.new(
            amount: @amount,
            customer_id: customer.id
          )
          if await.save
            #mise a jour du montant du customer
            account = Account.where(customer_id: customer.id).first
            customer_amount = account.amount - @amount
            
            #on mets a jour la table customer sur await
            if customer.update(await: await.id) && account.update(amount: customer_amount)
              #---------------send sms to customer--------------
              Sms.new(@phone, "Vous allez effectuer un retrait d un montant de #{@amount} #{$devise}. Bien vouloir cliquer sur retrait sur votre telephone. #{$signature}")
              Sms::send
              Rails::logger::info "Processus initialisé avec succes pour le numéro #{@phone}. Delais de #{5.minutes.from_now}"
              #puts "user await updated"
              return true, "Processus initialisé avec succes pour le numero #{@phone}"
            else
              #puts "user await canceled"
              Rails::logger::error "Processus de retrait du montant #{@phone}, d'un montant de #{@amount} a ete annulé."
              return false, "Impossible d\'initialiser le processus de retrait. Error : #{customer.errors.messages}'"
            end
            Rails::logger::info "Retrait initialisé pour le client #{@phone} on #{Time.now}."
            #puts "created new await"
            return true, "nouveau await cree"
          else
            Rails::logger::error "Impossible d'initialiser le retrait vers #{@phone} on #{Time.now}."
            return false, "Impossible d'initialiser le retrait. Procedure annulée."
          end
        else
          #le client n'est pas disponible sur la plateforme
          Rails::logger::error "Impossible d'initialiser le retrait vers #{@phone}, Client inexistant."
          return false, "Impossible d'initialiser le retrait, Utilisateur inconnu ou disposant deja "
        end
      else
        Rails::logger::error "Impossible d'initialiser le retrait vers #{@phone} on #{Time.now}. Montant dans le compte client est insuffisant"
        return false, "Processus de annulé, Ce compte ne dispose pas assez d argent"
      end
        
    end

    # permet de payer  
    # @method name  Pay
    # @name         Client::pay
    # @params       emeteur, destinataire, montant, password 
    # @output       boolean [true/false]
    def self.pay(from, to, amount, pwd)
      @from = from.to_i
      @to = to.to_i
      @amount = amount.to_f                                               #montant de la transation
      @client_password = pwd

      marchand = Customer.find(@to)                                       #personne qui recoit
      marchand_account = Account.where(customer_id: marchand.id).first    #le montant de la personne qui recoit
      client = Customer.find(@from)                                       #la personne qui envoi
      client_account = Account.where(customer_id: client.id).first        # le montant de la personne qui envoi

      if @from == @to
        Sms.new(@from, "Vous ne pouvez pas vous payer a vous meme!. Transaction annulee. #{$signature}")
        Sms::send
        Rails::logger::info "Numéro indentique, transaction annuler!"
        return false, " Vous ne pouvez pas vous payer à vous même!"
      else
        if client.valid_password?(@client_password)
          Rails::logger::info "Client identifié avec succes!"

          #contrainte si le montant depasse 150 000 F CFA XAF
          if @amount > $limit_amount
            Rails::logger::info "Limite de transaction de 150 000 F depassée"
            return false, "Vous ne pouvez pas faire une transaction au dela de 150 000 F."
          else
            if client_account.amount.to_f >=  Parametre::Parametre::agis_percentage(@amount) #@amount.to_i
              Rails::logger::info "Le montant est suffisant dans le compte du client, transaction possible!"
              hash = "PP_#{SecureRandom.hex(13).upcase}"
              client_account.amount = Parametre::Parametre::soldeTest(client_account.amount, amount) #client_account.amount.to_f - Parametre::Parametre::agis_percentage(@amount).to_f #@amount
              if client_account.save
                Rails::logger::info "Solde tm : #{client_account.amount.to_f}"
                marchand_account.amount += @amount 
                marchant = Transaction.new(
                  customer: @to,
                  code: hash,
                  flag: "credit",
                  context: "none",
                  date: Time.now,
                  amount: Parametre::Parametre::agis_percentage(@amount)
                )
  
                #on enregistre
                marchant.save
  
                if marchand_account.save
                  Sms.new(marchand.phone, "Vous avez recu un paiement d un montant de #{@amount} F CFA provenant de Mr/Mme #{client.name} #{client.second_name}. La transaction c\'est correctement terminee. Votre solde est maintenant de #{marchand_account.amount} F CFA. ID Transaction : #{hash}. #{$signature}")
                  Sms::send
                  #--------------------------------------------------
                  Sms.new(client.phone, "Mr/Mme #{client.name} #{client.second_name}, #{Parametre::Parametre::agis_percentage(@amount)} F CFA ont ete debite de votre compte, le solde actuel de votre compte est #{client_account.amount} F CFA. ID Transaction : #{hash}. Merci de nous faire confiance. #{$signature}")
                  Sms::send
                  #----------------------------------------------------
                  Rails::logger::info "Paiement effectué de #{@amount} entre #{@from} et #{@to}."
  
                  #journalisation de l'historique
  
                  #History::History.new(marchand.authentication_token, client.authentication_token, @amount, "phone", "paiement")
                  #History::History::history(@from, @to, @amount, "phone", "paiement", hash)
                  transaction = Transaction.new(
                    customer: @from,
                    code: hash,
                    flag: "debit",
                    context: "none",
                    date: Time.now,
                    amount: @amount
                  )
  
                  if transaction.save
                    Rails::logger::info "Transaction enregistrée avec succes"
                  end
  
                  #fin de journalisation
  
                  #enregistrement des commissions
                  Parametre::Parametre::commission(hash, @amount, Parametre::Parametre::agis_percentage(@amount).to_f, (Parametre::Parametre::agis_percentage(@amount).to_f - @amount))
                  return true, "Votre Paiement de #{@amount} F CFA vient de s'effectuer avec succes. \n Frais de commission : #{Parametre::Parametre::agis_percentage(@amount).to_f - @amount} F CFA. \n\n Total prelevé de votre compte : #{Parametre::Parametre::agis_percentage(@amount).to_f} F CFA."
                else
                  Rails::logger::info "Marchand non credite de #{@amount}"
                  Sms.new(marchand.phone, "Impossible de crediter votre compte de #{amount}. Transaction annulee. #{$signature}")
                  Sms::send
                  return false
                end
              else
                Rails::logger::info "Client non debite du montant #{@amount}"
                Sms.new(client.phone, "Impossible d\'acceder a votre compte. Transaction annulee. #{$signature}")
                Sms::send
                return false
              end
            else
              Rails::logger::info "Le solde de votre compte est de : #{marchand_account.amount}. Paiment impossible"
              Sms.new(client.phone, "Le montant dans votre compte est inferieur a #{amount}. Transaction annulee. #{$signature}")
              Sms::send
              return false, "Le solde de votre compte est insuffisant."
            end
          end
        else
          Rails::logger::info "Invalid password aythentication"
          Sms.new(client.phone, "Mot de passe invalide. Transaction annulee. #{$signature}")
          Sms::send
          return false
        end
      end
    end

    def self.transfert(from, to, amount, password)
      @from = from
      @to = to
      @amount = amount
      @client_password = password
      if (@from == @to)
        Sms.new(@from, "Expediteur et Receveur ne peuvent etre identique, merci de changer. #{$signature}")
        Sms::send
        return "#{@from} et #{@to} ne peuvent etre indentique. #{$signature}"
      else
        #on commernce par rechercher si le receveur appartient au reseaux
        marchand = Customer.where(phone: @to).first                           #personne qui recoit
        marchand_account = Account.where(customer_id: marchand.id).first      #le montant de la personne qui recoit
        client = Customer.where(phone: @from).first                           #la personne qui envoi
        client_account = Account.where(customer_id: client.id)                # le montant de la personne qui envoi
        #on authentifie le client a l'aide de son telephone et de son password
        if client.valid_password?(@client_password)
          if (client_account.amount >= @amount)
            hash = SecureRandom.hex(13).upcase
            marchand_account.amount = marchand_account.amount + @amount
            if marchand_account.save
              client_account.amount = client_account.amount - @amount

              #on inscrit dans l'historique du marchand
              Journal::Journal::create_logs_transaction(@from, @to, @amount, "credit")
              if client_account.save

                #on inscrit le journal du client concernant sa transaction
                Journal::Journal::create_logs_transaction(@to, @from, @amount, "debit")

                #Envoi des SMS de confirmations de la transaction
                Sms.new(@to, "Le paiement du montant #{@amount} F CFA provenant de #{client.name} #{client.second_name} c est correctement deroule. Votre solde est maintenant de #{marchand_account.amount} F CFA. ID Transaction : #{hash}. #{$signature}")
                Sms::send
                #----------------------------------
                Sms.new(@from, "Mr/Mme #{client.name} #{client.second_name}, #{@amount} F CFA ont ete debite de votre compte, le solde actuel de votre compte est #{client_account.amount} F CFA. ID Transaction : #{hash}. #{$signature}")
                Sms::send
                return "Le paiement du montant #{@amount} F CFA provenant de #{client.name} #{client.second_name} c est correctement deroule. ID Transaction : #{hash}. #{$signature}"
              else
                return "Echec du paiement du montant #{@amount} F CFA. Echec de la transaction ID Transaction : #{hash}. #{$signature}"
              end
            else
              return "une erreur est survenue durant le traitement"
            end
            else
              Sms.new(@from, "Montant du compte insuffisant. #{$signature}")
              return "Impossible d'effectuer le transfert, le montant est insuffisant"
          end
        else
          Sms.new(@from, "Transaction annulee, mot de passe invalide. #{$signature}")
          Sms::send
        end
      end
    end
end