class Client

  $signature = "PayMeQuick"
  $appname = "PayMeQuick"
  $domain = "paymequick.com"
  $version = "0.0.1beta-rev-11-03-83-50"
  $limit_amount = 150000
  $limit_transaction_recharge = 500000
  $limit_transaction_recharge_jour = 2500000 # soit 5 recharges par jour
  $limit_day_transaction = 100
  $devise = "F CFA"
  $status = {
      false: :false
  }

  # create new logger file
  @push_logger = ::Logger.new(Rails.root.join('log', 'client.log'))


  # @param [Object] from
  # @param [Object] to
  # @param [Object] amount
  # @param [Object] pwd
  # @return [Object] nil
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
  def initialize(from, to, amount, pwd)
    $from = from
    $to = to
    $amount = amount
    $pwd = pwd
  end


  #CREATION DU COMPTE CLIENT :: refactoring
  # @param [String] name
  # @param [String] second_name
  # @param [Integer] phone
  # @param [String] cni
  # @param [String] password
  # @param [String] sexe
  # @param [Integer] question
  # @param [String] answer
  # @param [String] IP
  # @version 1.0.1
  def self.signup(argv, message, locale)
    include ActionDispatch

    begin

      @name = argv[:name]
      @second_name = argv[:second_name]
      @phone = argv[:phone]
      @cni = argv[:cni]
      @email = "#{Faker::Internet.email}"
      @password = argv[:password]
      @sexe = argv[:sexe]
      @ip = argv[:ip]
      @question = argv[:question]
      @answer = argv[:answer]

      @locale = locale # Pour la traduction, fr ou en

      #on recherche le pays
      @pays = DistanceMatrix::DistanceMatrix.pays(@ip)

      Rails::logger::info "Requete provenant de l'IP #{@ip}, du pays : #{@pays}"

      # Check if password is don't rejected ::  FRAUD inclusion
      if Fraud::Customer.passwordValidation(@password)[0]

        # password is OK and don't have restricted informations
        #initi customer creation
        customer = Customer.new(
            name: @name,
            second_name: @second_name,
            phone: @phone,
            email: @email,
            password: @password,
            type_id: 1,
            cni: @cni,
            sexe: @sexe,
            ip: @ip,
            pays: @pays
        )

        Customer.transaction do

          if customer.save

            # on enregistre la question de securité
            pSecurityQuestion = Parametre::SecurityQuestion::setSecurityQuestion(customer.id, @question, @answer)
            Rails::logger::info "Sauvegarder des données personnelles : #{pSecurityQuestion}"

            @otp = Parametre::Authentication::auth_top(@phone)
            if @otp[0]
              Rails::logger::info "Le compte #{@phone} vient de se faire envoyer le SMS de confirmation"
              return true, customer.as_json(only: :phone)
            else
              #notified admin for these errors, customer could not receive SMS confirmation

              Sms.sender(App::PayMeQuick::App::developer[:phone], App::Messages::Signup::confirmation[:sms][:confirmation_failed])

              return @otp[1], I18n.t("SmsNotSend", locale: @locale) #"Hum!!! c'est vraiment génant, nous sommes dans l'incapacité de vous transmettre le SMS de confirmarion"

            end

          else
            #Rails::logger::info {"Creation de de l'utiliateur #{@phone} impossible : #{customer.errors.full_messages}"}

            Sms.sender(App::PayMeQuick::App::developer[:phone], App::Messages::Signup::confirmation[:sms][:customer_exist])

            return false, "Des erreurs sont survenues : #{customer.errors.full_messages}"

          end
          #raise ActiveRecord::Rollback, "Call tech support"
        end

      else

        #this password is restricted
        return false, I18n.t("PasswordNotSecure", locale: @locale) #"Le mot de passe que vous avez choisis est non seulement faible, mais pour des raisons de securité est interndit. Merci de le modifier et de réessayer"

      end

    rescue ActiveRecord::Error::ConnectionError
      puts "Une erreur est survenue"
    rescue ArgumentError => e
      puts "Une autre erreur est survenue : #{e}"
    end
  end

  #CREATION DU COMPTE CLIENT
  # @params  [String] name
  # @params  [String] prenom
  # @params  [Integer] phone
  # @params  [String] cni
  # @params  [String] password
  # @params  [String] sexe
  # @return  [Boolean] boolean
  # @version 1.0.0
  # @param [String] ip
  def self.create_user(name, prenom, phone, cni, password, sexe, ip)
    @name = name
    @prenom = prenom
    @phone = phone
    @cni = cni
    @email = "#{@phone.to_i}@#{$domain}"
    @password = password
    @sexe = sexe
    @ip = ip

    #on recherche le pays
    @pays = DistanceMatrix::DistanceMatrix.pays(@ip)

    #creation du compte de l'utilisateur
    @customer = Customer.new(
        name: @name,
        second_name: @prenom,
        phone: @phone,
        email: @email,
        password: @password,
        type_id: 1,
        cni: @cni,
        sexe: @sexe,
        ip: @ip,
        pays: @pays
    )

    if @customer.save
      Rails::logger::info {"Creation de de l'utiliateur #{@phone} avec succes."}

      #on envoi le code d'authentification pour verification
      @otp = Parametre::Authentication::auth_top(@phone, 'context')
      if @otp[0]
        return true, "Le compte #{@phone} vient de se faire envoyer le SMS de confirmation"
      else
        #notified admin for these errors

        ApiMailer.create_notifyAdmin

        return @otp[1], "Impossible de transmettre le SMS de confirmarion"
      end
    else
      Rails::logger::info {"Creation de de l'utiliateur #{@phone} impossible : #{@customer.errors.full_messages}"}
      return false, "Echec de creation du profil personnel. code erreurs : #{@customer.errors.full_messages}"
    end
  end

  #CREATION DU COMPTE VIRTUEL FINANCIER UTILISATEUR
  # @name     Client::create_user_account(id:integer, phone:integer)
  # @detail   Permet de creer un compte utilisateur sur la plateforme
  # @params   [object] phone
  # @return   boolean
  # @author @mvondoyannick
  # @version 1.0.1
  def self.create_user_account(phone)
    Rails::logger::info "Demarrage de la creation du compte utilisateur ..."
    #@id = id
    @phone = phone

    #recherche du customer
    #customer = Customer.exists?(phone: @phone)
    @customer = Customer.find_by_phone(phone)
    if @customer.blank?
      Rails::logger::info "Utilisateur #{@phone} est inconnu"

      return false, "Utilisateur inconnu"
    else
      account = Account.new(
          amount: 0.0,
          customer_id: @customer.id
      )

      if account.save

        # Ajout de l'abonnement basique pour ce client
        #Rails::logger::info "Ajout de l'abonnement basique pour ce customer #{@customer.id}"
        #Abonnements::Abonnements.add(1, @customer.id)

        Rails::logger::info "Utilisateur #{@customer.phone} crée a #{Time.now}"

        return true, "creation porte-monnaie effectué avec succes!"

      else

        Sms.sender(@customer.phone, "Une erreur est survenue durant le processus de creation compte virtuel! Merci de patienter, un agent PayMeQuick va vous contacter d'ici peu. #{$signature}")

        # envoi du courriel de notification aux administrateurs
        Sms.sms_to_many({yan: 691451189, nana: 698500871, boss: 697970210}, "Une erreur est survenue durant le processus de creation de compte : Impossible de creer le compte viertuel pour #{@customer.photo}")
        # fin de notification
        return false, "Echec de creation du porte monnaie virtuel #{App::PayMeQuick::App.app[:signature]} pour le compte #{@customer.phone}: #{account.errors.full_messages}"

      end
    end

  end


  #CREDIT DU COMPTE VIRTUEL DU CLIENT
  # @param [Object] phone
  # @param [Object] amount
  # @author @mvondoyannick
  # @version 1.0.1
  # @return [Object]
  def self.credit(phone, amount)
    @phone = phone
    @amount = amount

    #on rechercher le user pour avoir sont ID
    customer = Customer.find_by_phone(@phone)
    if customer.blank?
      return false, "Aucune utilisateur ne correspond."
    else
      @account = customer.account
      if @account.blank?
        #puts "Auccun compte correspondant trouve."
        return false, "Auccun compte correspondant trouvé appartenant à #{customer.phone}."
      else
        # Refactoring on incrementation
        #@account.amount.to_i += @amount.to_i

        if @account.update(amount: @account.amount.to_f + @amount.to_f)

          # Generate hash of transaction
          @hash = "PR_#{SecureRandom.hex(13).upcase}"

          transaction = History.new(
              customer_id: customer.id,
              code: @hash,
              flag: "recharge".upcase,
              context: "none",
              # date: Time.now.strftime("%d-%m-%Y @ %H:%M:%S"),
              amount: @amount
          )

          # on enregistre la transaction
          if transaction.save
            Sms.sender(customer.phone, "#{prettyCallSexe(customer.sexe)} #{customer.complete_name}, votre compte vient d etre crediteé d'un montant de #{@amount} #{App::PayMeQuick::App::devise}. Le solde de votre compte est actuellement de #{customer.account.amount} #{App::PayMeQuick::App::devise}. ID Transaction : #{@hash}. #{App::PayMeQuick::App::app[:signature]}")
            #puts "Le compte a ete credite d\'un montant de #{@amount}"
            return "Le compte a ete credite d\'un montant de #{@amount}."
          else
            #puts "impossible de sauvegarder"
            return "Impossible de sauvegarder votre activité"
          end

        else

          Sms.sender(@phone, "#{prettyCallSexe(customer.sexe)} #{customer.complete_name}, impossible de crediter votre compte. Echec de la Transaction #{@hash}. #{App::PayMeQuick::App::app[:signature]}")

          return false, "Impossible de crediter votre le compte #{App::PayMeQuick::App::app[:signature]}. code erreurs : #{@account.errors.full_messages}"

        end
      end
    end
  end


  #CHECK CUSTOMER DEVICE ID
  # detail verify if customer Device has been change on new login
  # param [Object] argc
  # TODO update customer locale for translation
  def self.device(argc, locale)
    @device = argc[:device] # devise here mean the smartphone uuid
    @phone = argc[:phone]
    @locale = locale

    # verify customer device
    customer = Customer.find_by_phone(@phone)
    if customer.blank?
      return false, I18n.t("customerNotFound", locale: @locale)
    else
      if customer.device.nil?

        #first time customer login on the plateform
        Rails::logger.info "Mise à jour de l'uuid du customer avec la valeur #{@device}"
        if customer.customer_datum.update(uuid: @device)

          # mise a jour de la valeur de trouvant dans customer.device
          if customer.update(device: @device)

            Rails::logger::info "Mise à jour des données de l'utilisateur reussi"
            return true #, "Welcome to first login on PayCore #{customer.name}"

          else

            puts "Fail to update main device"
            return false, "Impossible de valide ce terminal"

          end

        else

          Rails::logger.info "Impossible de mettre votre device UUID a jour"
          return false #, "send SMS for confirmation authentication on the new device"

        end
      else
        if customer.device == @device

          Rails::logger::info "UUID est indentique, authentication continu"
          return true

        else
          # Update new device to customerDatum.uuid2
          if customer.customer_datum.update(uuid2: @device)

            Rails::logger::info "Mise a jour de l'UUID 2 effectuée avec la value #{@device} pour le nouveau terminal"
            return false #Updated

          else

            Rails::logger::info "Impossible de mettre a jour l'UUID 2"
            return false #Unable to updated

          end
        end
      end
    end

  end


  #UPDATE DEVICE NEW UUID CUSTOMER
  # @param [Object] argc
  def self.updateDevice(argc)
    @uuid = argc[:uuid]
    @phone = argc[:phone]
    @sms = argc[:sms]

    customer = Customer.find_by_phone(@phone)
    if customer.blank?
      return false, "Customer Unknow" #I18n.t('lore')
    else
      # check SMS and
      data = CustomerDatum.find_by(customer_id: customer.id, uuid2: @uuid, phone: @phone)

      if data.blank?

        Rails::logger::info "Rien de similaire trouvé, les UUID2 ne sont pas correspondant"
        return false, "Il semble que vous essayez d'acceder à partir d'un nouveau terminal non reconnu. Pour des raisons de sécurité, merci de confirmer qu'il s'agis bien de vous!!"

      else
        # request SMS authentication
        if customer.two_fa == @sms
          Rails::logger::info "Update information two_fa of customer"
          if customer.update(two_fa: 'authenticate')

            #mise a jour de l'uuid premium
            if customer.update(device: @uuid)

              Rails::logger::info "Customer has be authenticated ... welcome Mr #{customer.name}"
              return true, "Utilisateur authentifié avec succès. Content de vous revoir Mr/Mme #{customer.name} #{customer.second_name}"

            else

              Rails::logger::info "Impossible de mettre a jour le nouvel UUID"
              return false, "Impossible d'ajouter votre nouveau terminal sur #{App::PayMeQuick::App::app[:signature]}"

            end
          else
            Rails::logger::info "Update two_fa is impossible"
            return false, "Impossible de mettre à jour vos information d'authentication"
          end
        else
          Rails::logger::info "Les informations du SMS ne sont pas indentique"
          return false, "Le code SMS ne semble pas etre correcte, merci de réessayer!"
        end
      end
    end
  end

  #AUTHENTIFICATION-CONNEXION D'UN UTILISATEUR SUR LA PLATEFORME
  # @name Client::signin
  # @author @mvondoyannick
  # @version 1.0.1.1
  # @param [Object] argc
  # @param [Object] locale
  # @param [Object] message
  def self.signin(argc, locale, message) # prévoir l'ajout de l'@ IP
    @phone = argc[:phone] # Customer phone account
    @password = argc[:password] # customer password account
    @device_id = argc[:device_id] # customer uniq device ID
    @locale = locale
    @message = message

    Rails::logger::info "Authenticating user #{@phone} call ..."

    #customer = Customer.where(phone: @phone).first
    customer = Customer.find_by_phone(@phone) # REFACTORING
    if !customer.blank?
      if customer.valid_password?(@password)
        if customer.two_fa == "authenticate"

          # check customer device
          if device({device: @device_id, phone: @phone}, @locale)

            # a ce stade, tout est true, donc tout va bien
            # on retourne les informations
            Rails::logger::info "Utilisateur et device indentique"

            # sending push notification to say welcome to customer

            return true, customer.as_json(only: [:name, :second_name, :authentication_token, :code])

          else

            # rien ne va!
            Rails::logger::info "Les informations du terminal de cet urilisateur sont differents de ceux contenu dans la base, il doit s'authentifier"

            # sending SMS to authenticate customer
            @codeSms = Parametre::Authentication::auth_top(@phone, 'context')
            if @codeSms[0]

              return true, I18n.t("enterSms", locale: locale), "authenticate"

            else

              return false, "Nous rencontrons des difficultés pour vous faire parvenir votre code SMS, un opérateur #{App::PayMeQuick::App::app[:signature]} vous contactera sous une minute."

            end

          end
        else
          @account_status = isLock?(customer.authentication_token)

          Rails::logger::info "Compte #{@phone} est actuellement #{customer.two_fa}"
          return false, "Le statut actuel de votre compte ne vous permet pas de vous connecter. Bien vouloir vous rapprocher d'un POINT #{App::PayMeQuick::App::app[:signature]} ou réinitialiser votre mot de passe."
        end
      else
        Rails::logger::error "Authenticating user failed, bad password. end request!"

        # on enregistre cet essaie de mauvais mot de passe dans la base de données, ainsi les informations supplementaires

        return false, "Utilisateur inconnu ou mot de passe invalide."
      end
    else
      Rails::logger::error "Authenticating user failled, unknow user. end request!"
      return false, I18n.t("customerNotFound", locale: @locale), status: :unauthorized #"Utilisateur inconnu ou mot de passe invalide.", status: :unauthorized
    end
  end

  #VERIFICATION DE LA FRAUDE SUR LA PLATEFORME
  # @name     isFraud
  # @detail   Permt de determiner d'eventuel systeme de fraude
  # @param [Object] phone
  # @param [Object] sim_phone
  # @param [Object] network_operator
  # @param [Object] uuid
  # @param [Object] imei
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
  def self.isFraud?(phone, sim_phone, network_operator, uuid, imei)
    @phone = phone
    @sim_phone = sim_phone
    @network_operator = network_operator
    @uuid = uuid
    @imei = imei
    #test if phone and sim_phone are same
    if @phone.eql?(@sim_phone)
      #on recherche les information dans la base de données customerData
      customer = Customer.find_by_phone(phone)
      if customer.blank?
        Rails::logger::info "Utilisateur Impossible à identifier"
        return false, "Utilisateur inconnu"
      else
        #recherche dans la table customerData
        antiFraud = customer.customer_datum
        if antiFraud.blank?
          Rails::logger::info "Utilisation frauduleuse detectée"
          return false, "Faude detectée"
        else
          #comparaison des differentes informations recues
          if @phone.eql?(antiFraud[:phone]) && @sim_phone.eql?(antiFraud[:sim_phone]) && @network_operator.eql?(antiFraud[:network_operator]) && @uuid.eql?(antiFraud[:uuid]) && @imei.eql?(antiFraud[:imei])
            Rails::logger::info "Utilisateur et terminal compatible."
            return true, "Client et mobile authenticated"
          else
            Rails::logger::info "des informations divergentes ont été trouvées."

            # Bloquer le compte du client

            result = lockCustomerAccount(phone, "Informations divergentestrouvées")
            if result[0]
              Rails::logger::info "#{result[1]}"
              return true, result[1]
            else
              Rails::logger::info "#{result[1]}"
              return true, result[1]
            end
          end
        end
      end
    else
      Rails::logger::info "Numero carte SIM et numero de compte ne sont pas identiques."
      #envoi du SMS sur sim_phone
      Sms.new(sim_phone, "La plateforme ne reconnais pas votre carte SIM!")
      Sms::send
      # fin d'envoi
      return false, "Les numéro de votre carte SIM et celui de ce compte #{App::PayMeQuick::App::app[:signature]} sont differents."
    end
  end


  #BLOCAGE D'UN COMPTE UTILISATEUR SUR LA PLATEFORME
  # @description
  # @name
  # @detail
  # @param [Object] phone
  # @param [Object] motif
  # @return [Object]
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
  def self.lockCustomerAccount(phone, motif)
    @phone = phone
    @motif = motif

    # recherche effective du customer
    customer = Customer.find_by_phone(phone)
    if customer.blank?
      Rails::logger::info "Utilisateur inconnu"
      return false, "Utilisateur inconnu"
    else
      #on verifie effectivement si le compte est bloqué
      verrou = isLock?(customer.authentication_token) #le verrou de securité
      if verrou[0]
        #il est effectivement bloqué, on le debloque
        if customer.update(two_fa: "authenticate")
          Rails::logger::info "Utilisateur #{customer.phone} vient d'etre debloqué"

          #envoi du SMS
          Sms.sender(customer.phone, "Votre compte #{customer.phone} vient d'etre debloqué.")

          return true, "Compte #{customer.phone} debloqué avec succes!"

        else

          return false, "Ce compte #{customer.phone} est actuellement bloqué."
        end

      else
        Rails::logger::info "Impossible de debloquer  le compte #{customer.phone}"
        return false, verrou[1]
      end
    end
  end


  #GET CREDIT BALANCE ACCOUNT REFACTORING
  # @param [Object] argv
  def self.balance(argv, locale)
    @phone = argv[:phone]
    @password = argv[:password]
    locale = locale

    begin

      @customer = Customer.find_by_phone(@phone)
      if @customer.blank?
        raise ActiveRecord::RecordNotUnique
      else
        if @customer.valid_password?(@password)
          # We can now render customer amount
          amount = @customer.account.amount

          # send SMS to customer
          Sms.sender(@customer.phone, "Bonjour #{@customer.complete_name} le solde de votre compte est de #{amount} F CFA")

          return true, amount
        else
          return false, "Invalid password"
        end
      end

    rescue ActiveRecord::RecordNotFound

      return false, "Utilisateur inconnu"

    rescue ActiveRecord::ConnectionNotEstablished

      return false, "Impossible de contacter le serveur"

    end

  end


  #OBTENIR LE SOLDE DU COMPTE
  # @name
  # @detail
  # @param [Object] tel
  # @param [Object] password
  # @return [Object]
  # @author @mvondoyannick
  # @version 1.0.1.1
  def self.get_balance(argv, message=nil , locale)
    @phone = argv[:phone]
    @password = argv[:password]
    message = message
    locale = locale

    #on recherche le client
    customer = Customer.find_by_phone(@phone)
    if customer.blank?
      Rails::logger::error "Authenticating user failed, unknow user. end request!"
      return false, I18n.t("customerNotFound", locale: locale)
    else
      if customer.valid_password?(@password)
        # account = Account.find_by_customer_id(query.id)
        # starting refactoring account
        account = customer.account.amount
        if account.blank?
          return false, "Aucun compte utilisateur correcpondant ou compte vide"
        else
          #return OneSignal API
          Sms.sender(@phone, "#{prettyCallSexe(customer.sexe)} #{customer.complete_name}, le solde de votre compte est : #{account} #{$devise}. #{App::PayMeQuick::App::app[:signature]}")
          return true, "#{prettyCallSexe(customer.sexe)} #{customer.complete_name}, le solde de votre compte est : #{account} #{$devise}. #{$signature}"
        end
      else

        return false, I18n.t("passwordInvalid", locale: locale)

      end
    end
  end


  #RETOURNE UNE APPELLATION CONVIVIALE DE L'UTILISATEUR
  # @param [String] sexe
  # @version 1.0.1
  def self.prettyCallSexe(sexe)
    @sexe = sexe.downcase
    case @sexe
    when "masculin"
      return "M."
    when "feminin"
      return "Mme/Mlle"
    else
      return "M./Mlle/Mme"
    end
  end


  #MISE A JOUR DES MONTANTS DU COMPTES
  # @param [Object] id
  # @param [Object] amount
  # @return [Object]
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
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


  #MISE A JOUR DES MONTANTS DU COMPTE MARCHAND
  # @param [Object] id
  # @param [Object] amount
  # @return [Object]
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
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

  #VERIFICATION DU STATUT D'UN COMPTE Bloquer|voler|desactiver|autre
  # @name
  # @detail   permet de verifier si un compte est actuellement bloquer ou non
  # params    token:string
  # @param [Object] token
  # @author @mvondoyannick
  # @version 1.0.1
  def self.isLock?(token)
    @token = token
    customer = Customer.find_by_authentication_token(@token)
    if customer.blank?
      return false, "Utilisateur inconnu"
    else

      case customer.two_fa
      when "authenticate"

        Rails::logger::info "Utilisateur #{customer.phone} authentifié sur #{App::PayMeQuick::App::app[:signature]}"
        return false, "authenticate", "Compte non bloqué", "Aucun motif"

      when "lock"

        Rails::logger::info "Utilisateur #{customer.phone} bloqué"
        return true, "locked", "Compte #{customer.phone} bloqué.", "Aucun motifs"

      when "delete"

        # end notification
        Rails::logger::info "Utilisateur #{customer.phone} supprimé sur #{App::PayMeQuick::App::app[:signature]}"
        return true, "deleted", "Ce compte a ete supprimer"

      else

        Rails::logger::info "Utilisateur #{customer.phone} rencontre des erreurs, valeurs incoherentes trouvées"
        return true, "Des erreurs ont ete identifiées sur ce compte, merci de vous rapprocher d'une agence partenaire #{App::PayMeQuick::App::app[:signature]}"

      end
    end
  end


  #RECHERCHE D'UN CLIENT SUR LA PLATEFORME
  # @param [Object] customer_id
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
  # @return [Object] customer
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
  def self.find_client(customer_id)
    @customer = customer_id
    customer = Customer.find(@customer)
    if customer.blank?
      return false, "Utilisateur inconnu"
    else
      return true, customer
    end
  end

  # RECHERCHE LE RECEVEUR OU LE MARCHAND
  # @param [Integer] id
  # @author @mvondoyannick
  # @version 1.0.0
  def self.find_marchand(id)
    @receiver_id = id
    query = Customer.find(id)
    if query.blank?
      Rails::logger::error "Impossible de terminer cette requete, utilisateur inconnu"
      return false, "Utilisateur inconnu"
    else
      Rails::logger::info "Utilisateur identifié"
      return true, query[:id]
    end
  end

  #DEBITER LE COMPTE D UN CLIENT
  # @param [Object] id
  # @param [Object] amount
  # @param [Object] signature
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
  def self.debit_client(id, amount, signature)
    @id = id
    @amount = amount
    @signature = signature

    response = find_client(id)
    if !response[0]
      Rails::logger::info "Utilisateur inconnu"
      return false
    else
      #on recherche le compte de ce client
      account = Account.find_by_customer_id(response[1])
      if account.blank?
        Rails::logger::info "Impossible de trouver le compte client"
      end
    end
  end

  #DEBIT LE COMPTE UTILISATEUR DURANT LA PROCEDURE DE RETRAIT
  # @param [Object] phone
  # @param [Object] amount
  # @author @mvondoyannick
  # @version 1.0.0
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
        if account.update(customer_id: customer.id, amount: account.amount)
          transaction = History.new(
              customer: customer.id,
              code: @hash,
              flag: "recharge".upcase,
              context: "none",
              # date: Time.now.strftime("%d-%m-%Y @ %H:%M:%S"),
              amount: @amount
          )

          if transaction.save

            Rails::logger::info "Compte debité avec succes"
            return true, "Compte #{customer.phone} debité avec succes"

          else

            Rails::logger::info "Impossible de mettre a jour les informations client"
            return false, "Des erreurs sont survenues durant le traitement de ceertaines informations : #{transaction.errors.full_messages}"

          end
        end
      end
    end
  end


  #VALIDATION DU RETRAIT PAR LE CUSTOMER :: REFACTORING UPDATE
  # @param [String] token
  # @param [String] pwd
  # @author @mvondoyannick
  # @version 1.0.1
  # TODO ajouter l'agent de la requete, celui qui initie l'oparation et retrait et se voit virer l'argent une fois la validation effectuée
  # TODO verifier et finaliser cette procedure de validation de retrait
  def self.validate_retrait(token, pwd)
    @token = token
    @pwd = pwd
    @hash = "PR-#{SecureRandom.hex(13).upcase}" #ID de la transaction

    customer = Customer.find_by_authentication_token(@token)
    # refactoring

    if customer.blank?
      Rails::logger::info "Utilisateur inconnu"
      return false, "Utilisateur inconnu"
    else
      if customer.valid_password?(@pwd)

        # Recherche si le customer a une intention de retrait
        awaits = customer.await
        if awaits.blank?
          # Can't continu, not intend await found

          Rails::logger.info "Aucun retrait trouvé pour #{customer.complete_name}"
          return false, "Aucun retrait trouvé pour votre compte #{customer.phone}"

        else
          # an await exist, continuation into process
          customer_abonnement = Abonnements::Abonnements.search(customer.id)

          # On recherche le palier d'abonnement du client et voir le max qu'il peut retirer
          if customer_abonnement[0]
            Rails::logger::info "#{customer.complete_name} a un palier lui permettant de faire un retrait maximum de #{customer_abonnement[1].to_i} F CFA"

            # Est ce que le montant a retirer est superieur a ce que le palier autorise?
            if customer.await.amount.to_f > customer_abonnement[1].to_f
              # Cancel retrait and restare fond
              Rails::logger.info "Plafond de retrait maximum atteint pour cette abonnement"

              # Starting restauration, and await suppression amount
              restauration = customer.await.amount

              if customer.account.update(amount: customer.account.amount + restauration.to_f)
                # before delete await, set it's amount to nil
                if awaits.update(amount: nil )
                  # delete customer await intend
                  if awaits.destroy
                    Rails::logger.info "Suppression de l'intention de retrait du customer ...DONE!"

                    # send notification
                    return false, "Ce retrait est au dessus de la limite maximum de votre plafond retrait, impossible effectuer le retrait. merci de revoir le montant à la baisse et de réessayer."
                  else
                    # si on ne peut pas detruire cela, on notify les administrateurs et on mets le compte a jour avec une valeur nil
                    Sms.sms_to_many({yannick: 691451189, nana: 698500871, boss: 697970210}, "Impossible de supprimer l'intention de retrait du client N° #{customer.complete_name} ayant l'ID #{await.id}")
                  end
                else
                  # force updating
                  awaits.update!(amount: nil )

                  #notify somes administrator
                  Sms.sms_to_many({yannick: 691451189, nana: 698500871, boss: 697970210}, "Impossible de supprimer l'intention de retrait du client N° #{customer.complete_name} ayant l'ID #{await.id}")
                end

              else
                # Failed to update customer restauration
                # raise ActiveRecord::Rollback "Restauration en cours ..."
                Rails::logger.info "Une erreur est survenue durant la restauration du compte #{customer.complete_name}, impossible de restaures son compte"

                # Notify admins
                Sms.sms_to_many({yannick: 691451189, nana: 698500871, boss: 697970210}, "Impossible de restaurer le compte du client N° #{customer.complete_name} ayant l'ID #{customer.id}, merci de rapidement intervenir!")

                raise ActiveRecord::Rollback "Reinitialisation des comptes aux status initials"
              end
            else

              #il existe effectivement un intent de retrait pour ce customer
              #on verifie si ce retrait est encore valide ou perimé
              if Time.now > awaits.end.to_time
                Rails::logger::info "Intention de retrait périmé, retrait annulé!"

                # On effectue le rembourssement du retrait au client
                account = customer.account #Account.find_by_customer_id(customer.id)
                if account.blank?
                  Rails::logger::info "Impossible de trouver le compte de l'utilisateur #{customer.id}"
                  return false, "Compte inexistant"
                else
                  #processus de retrocession
                  # retro = account.amount += awaits.amount.to_f
                  # if account.update(amount: retro)
                  #   Rails::logger::info "Montant remboursé avec succes"
                  #
                  #   #on supprime ensuite l'intent de retrait dans Await
                  #   Rails::logger::info "Suppression de l'intent de retrait"
                  #   awaits.destroy
                  #
                  #   #on remet a jour le flag await sur le customer
                  #   Rails::logger::info "Mise a jour de user"
                  #   customer.update(await: nil)

                  Rails::logger::info "Suppression de l'intent de retrait ..."
                  awaits.destroy

                  return true, "Retrait perimé, impossible de continuer"
                  # else
                  #   Rails::logger::info "Impossible de mettre à jour le remboursement"
                  #   return false, "Votre rembourssement a echoué, merci de vous rapprocher d'une agence Express Union"
                  # end
                end
              else
                #tout va bien, on procede a la validation du retrait

                account = customer.account #Account.find_by_customer_id(customer.id)
                if account.blank?
                  Rails::logger::info "Compte inconnu"
                  return false
                else
                  # on debit effectivement le compte client
                  Rails::logger::info "Suppression de l'intent de retrait ..."

                  # introduction de l'agent dans le processus, credit du compte de l'agent
                  agent = customer.await.agent # Retourne le token de l'agent

                  # Credit du compte de l'agent
                  if Customer.find_by_authentication_token(agent).account.update(amount: customer.await.amount)
                    # save history
                    #enregistrement de l'historique du retrait
                    transaction = History.new(
                        customer_id: customer.id,
                        code: @hash,
                        flag: "retrait".upcase,
                        context: "none",
                        amount: awaits.amount.to_s
                    )

                    #on enregistre l'historique
                    if transaction.save

                      # on met a jour le compte de l'agent et on le notifie
                      customer_agent = Customer.find_by_authentication_token(agent)
                      if customer_agent.account.update(amount: customer_agent.amount.to_f + awaits.amount.to_f)
                        Rails::logger::info "Mise a jour du compte de l'agent qui a initialiser le process de retrait ... FAIT!"

                        # Notification de l'agent
                        Sms.sender(agent.phone, "Retrait effectué du compte #{customer.complete_name}. Credit de votre compte : #{agent.complete_name} d'un montant de #{awaits.amount.round(2)} F CFA. Votre solde total est de #{agent.account.amount.round(2)} F CFA. Vous pouvez payer !")

                        # on supprime l'intent de retrait
                        if awaits.destroy

                          return true, "#{awaits.amount} F CFA ont été retiré de votre compte. \t Votre solde est de #{account.amount} F CFA. Merci"

                        else

                          puts "Une erreur est survenue, engagement d'ActiveRecord::RollBack"
                          raise ActiveRecord::Rollback "Annulation de la transaction car Une erreur est survenu durant la transaction"
                          #return false, "Une erreur est survenu durant la transaction"

                        end
                      else

                        Rails::logger.info "Impossible de mettre a jour le compte de l'agent"

                      end

                    else
                      raise ActiveRecord::Rollback "Une erreur est survenue durant la mise à jour des informations. merci de vous rapprocher d'un point Express Union."
                      #return false, "Une erreur est survenue durant la mise à jour des informations. merci de vous rapprocher d'un point Express Union."
                    end
                  else
                    raise ActiveRecord::Rollback "Impossible de continuer"
                    # RollBack
                  end
                end
              end
            end
          else
            Rails::logger.info "Impossible de determiner le palier d'appartenance du customer"
            return false, "Impossible de determiner votre Palier, merci de vous abonner à un palier et de revenir effectuer un retrait "
          end
        end
      else
        Rails::logger::error "Mot de passe invalide pour ce compte. transaction annulée"
        return false, "Mot de passe invalide"
      end
    end

    # fin du refactoring
  end

  #VERIFICATION INTENT DE RETRAIT EST PERIME -- OU PAS
  # @method     name Verifier sur une procedure de retrait est encore valide
  # @name       Client::is_await_valide
  # @params     phone
  # @output     boolean [true/false]
  # @author @mvondoyannick
  # @version 1.0.1
  def self.is_await_valid?(phone)
    @phone = phone
    Rails::logger::info "Starting await verification ..."
    customer = Customer.find_by_phone(@phone)
    if customer.blank?
      Rails::logger::error "Utilisateur #{@phone} est inconnu du systeme"
      return false, "Utilisateur inconnu"
    else
      await = customer.await #Await.where(customer_id: customer.id).last
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


  #ANNULATION D UN RETRAIT DANS UN COMPTE CLIENT
  # @method   name Cancel current retrait by user
  # @name     Client::cancelRetrait
  # @params   phone, password, awaitHash
  # @output   boolean [true/false]
  # @author @mvondoyannick
  # @version 1.0.1
  def self.cancelRetrait(argv, message=nil , locale)
    token = argv[:token]
    message = message
    locale = locale

    #searching customer
    customer = Customer.find_by_authentication_token(token)
    if customer.blank?
      return false, I18n.t("customerNotFound", locale: locale)
    else
      # check existance of await
      Rails::logger.info "Searching intents for customer #{token}"
      intent = customer.await
      if intent.blank?
        return false , "Aucune intention de retrait disponible pour ce compte"
      else
        # we found an intent, we can destroy it
        # See restauration on Await model
        if intent.destroy
          # cancel and restore customer credit account
          return true, "Retrait annulé avec succes du montant de #{intent.amount.round(2)}"
        else
          return false, "Une erreur est survenue durant le processus d'annulation du retrait de #{intent.amount.round(2)} F CFA"
        end
      end
    end
  end

  #VERIFICATION DE L EXISTENCE D'UNE INTENTION DE RETRAIT EN COURS
  # @method   Check retrait | verifier le retrait
  # @name     Client::check_retrait
  # @params   phone
  # @output   boolean [true/false]
  # @author @mvondoyannick
  # @version 1.0.1
  def self.check_retrait(phone)
    @phone = phone
    customer = Customer.find_by_phone(@phone) #where(phone: phone).first
    if customer.blank?
      Rails::logger::info "Utilisateur inconnu"
      return false, "Utilisateur inconnu"
    else
      await = Await.find_by(customer_id: customer.id, id: customer.await)
      if await.blank?
        Rails::logger::info "Aucun retrait trouvé pour ce compte"
        return false, "Aucun retrait sur votre compte  pour le moment"
      else
        Rails::logger::info "Existance d'un retrait pour ce compte"

        #notification email
        #ApiMailer.notifyAdmin.deliver_now
        #ApiMailer.signupFail("MESSAGE", 691451189, Time.now, "ERRORS").deliver_now
        ApiMailer.notify("MESSAGE", 691451189, Time.now, "ERRORS").deliver_now
        # fin notification
        return true, await.as_json(only: :amount)
      end
    end
  end


  #VERIFICATION DE LA PRESENCE DE L'INTENT DE RETRAIT :: REFACTORING -- UPDATE
  # @param [Object] token
  # @author @mvondoyannick
  # @version 1.0.1
  def self.check_retrait_refactoring(token, locale)
    @token = token
    locale = locale

    customer = Customer.find_by_authentication_token(@token)
    if customer.blank?
      Rails::logger::info "Utilisateur inconnu"
      return false, I18n.t("customerNotFound", locale: locale) #"Utilisateur inconnu"
    else
      #on recherche le compte await du customer
      intent_retrait = customer.await
      if intent_retrait.blank?
        Rails::logger::info "Aucun retrait pour cet utilisateur"
        return false, I18n.t("noIntent", locale: locale) #"Aucun retrait pour ce compte."
      else
        Rails::logger::info "Intent retrait trouvé"
        return true, intent_retrait.as_json(only: :amount)
      end
    end
  end

  #AUTHENTIFICATION D UN USTOMER VIA LE HEADER RECU
  # @method name  Check Header for customer
  # @name         Client::checkHeader
  # @params       header
  # @output       boolean [true/false]
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
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

  #VERIFIER SI LE CLIENT DISPOSE DU SOLDE SUFFISA?T DANS SON COMPTE POUR EFFECTUER LA TRANSACTION
  # @method name  Get Balance before retrait
  # @name         Client::get_balance_retrait
  # @params       phone amount
  # @output       boolean [true/false]
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
  def self.get_balance_retrait(phone, amount_retrait)
    @phone = phone
    @amount = amount_retrait.to_i
    Rails::logger::info "Starting get balance for account #{@phone}, amount of #{@amount}"
    #on ne peut pas retirer moins de 500 F CFA XAF
    if @amount < 500
      Rails::logger::warn "Tentative de retrait d'un montant inferieur a 500F, Transaction annulée"
      return false
    else
      customer = Customer.find_by_phone(@phone)
      if customer.blank?
        Rails::logger::error "Utilisation inconnu, Transaction annulée."
        return false
      else
        customer_amount = customer.account.amount #Account.where(customer_id: customer.id).first.amount
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


  #INITIALISATION DE LA PROCEDURE DE RETRAIT
  # @method name  Get Balance before retrait
  # @name         Client::init_retrait
  # @params       [object] phone
  # @param        [object] amount
  # @return       boolean [true/false]
  # @author @mvondoyannick
  # @version 1.0.0
  # @OneSignal Adding oneSignal
  def self.init_retrait(phone, amount, agent)
    @phone = phone
    @amount = amount.to_i
    @agent = agent # Agent initialisateur de la procedure de retrait
    Rails::logger::info "Demarrage initialisation retrait pour #{@phone} ..."
    #se trouve dans la table retrait_await, on ajout un marqueur au client
    customer = Customer.find_by_phone(@phone)
    if customer.blank?
      return false, "Utilisateur inconnu"
    else
      if get_balance_retrait(@phone, @amount) #il a suffisament d'argent
        if customer.await.nil?
          #on creet un nouvel await
          await = Await.new(
              amount: @amount,
              customer_id: customer.id,
              agent: @agent
          )
          if await.save
            #mise a jour du montant du customer
            account = customer.account #Account.where(customer_id: customer.id).first
            customer_amount = account.amount.to_f - @amount.to_f

            #on mets a jour la table customer sur await
            if customer.account.update(amount: customer_amount)
              #---------------send sms to customer--------------
              #OneSignal::OneSignalSend.retraitOneSignal()
              Sms.new(@phone, "Vous allez effectuer un retrait d un montant de #{@amount} #{$devise}. Bien vouloir cliquer sur <<RETIRER>> sur dans l'application #{$signature}")
              Sms::send
              Rails::logger::info "Processus initialisé avec succes pour le numéro #{@phone}. Delais de #{5.minutes.from_now}"
              #puts "user await updated"
              return true, "Processus initialisé avec succes pour le numero #{@phone}"
            else
              #puts "user await canceled"
              Rails::logger::error "Processus de retrait du montant #{@phone}, d'un montant de #{@amount} a ete annulé."
              return false, "Impossible d\'initialiser le processus de retrait. Error : #{customer.errors.messages}'"
            end
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

  end

  #PERMET D EFFECTUER UN PAIEMENT D'UN CLIENT A UN AUTRE CLIENT
  # @method name  Pay
  # @name         Client::pay
  # @params       [object] emeteur
  # @param        [object] destinataire
  # @params       [object] montant
  # @params       [object] password
  # @output       [boolean] [true/false]
  # @author @mvondoyannick
  # @version 1.0.2
  def self.pay(from, to, amount, pwd, ip, lat, lon)
    @from = from.to_i
    @to = to.to_i
    @amount = amount.to_f #montant de la transation
    @client_password = pwd
    @ip = ip
    @lat = lat
    @lon = lon

    marchand = Customer.find(@to) #personne qui recoit
    marchand_account = marchand.account #Account.where(customer_id: marchand.id).first #le montant de la personne qui recoit
    client = Customer.find(@from) #la personne qui envoi
    client_account = client.account #Account.where(customer_id: client.id).first # le montant de la personne qui envoi

    if @from == @to
      #Send local Pushnotifications here
      #OneSignal::OneSignalSend.notPayToMe(@playerId, "#{client.name} #{client.second_name}") #sendNotification(@playerId, Parametre::Parametre.agis_percentage(@amount),"#{marchand.name} #{marchand.second_name}", "#{client.name} #{client.second_name}")
      # end sending local notifications
      Rails::logger::info "Numéro indentique, transaction annuler!"
      return false, {
          title: "ERREUR DE DESTINATAIRE",
          message: "#{prettyCallSexe(client.sexe)} #{client.complete_name} vous ne pouvez pas vous payer à vous même. Merci de verifier votre destinataire et réessayer."
      }
    else
      if client.valid_password?(@client_password)
        Rails::logger::info "Client identifié avec succes!"

        #contrainte si le montant depasse 150 000 F CFA XAF
        if @amount > $limit_amount
          Rails::logger::info "Limite de transaction de 150 000 F depassée"
          return false, {
              title: "LIMITE DE TRANSACTION",
              message: "#{prettyCallSexe(client.sexe)} #{client.complete_name} il semblerait que votre transaction dépasse la limité autorisée de #{$limit_amount} #{$devise}. Merci de revoir le montant de votre transaction."
          }
        else
          if client_account.amount.to_f >= Parametre::Parametre::agis_percentage(@amount)
            Rails::logger::info "Le montant est suffisant dans le compte du client, demarrage de la transaction ..."
            @hash = "PP_#{SecureRandom.hex(13).upcase}"
            # client_account.amount = Parametre::Parametre::soldeTest(client_account.amount, amount) #client_account.amount.to_f - Parametre::Parametre::agis_percentage(@amount).to_f #@amount
            if client_account.update(amount: Parametre::Parametre::soldeTest(client_account.amount, amount))
              # if client_account.save
              Rails::logger::info "Solde dans le compte du client #{client.phone} : #{client_account.amount.to_f}"
              marchand_account.amount += @amount

              #on historise la transaction du marche
              #saveHistory(@to, @hash,"ENCAISSEMENT","none",@amount,nil ,nil ,nil )
              marchant_log = History.new(
                  customer_id: marchand.id,
                  amount: @amount,
                  code: @hash,
                  flag: "encaissement".upcase,
                  context: "Mobile".upcase,
                  ip: @ip
              )

              #on enregistre
              marchant_log.save

              if marchand_account.save
                #envoi d'une notification OneSignal
                Sms.sender(marchand.phone, "Paiement recu. Montant :  #{@amount.round(2)} F CFA XAF, \t Payeur : #{prettyCallSexe(client.sexe)} #{client.complete_name}. Votre nouveau solde:  #{marchand_account.amount} F CFA XAF. Transaction ID : #{@hash}. Date : #{Time.now}. #{App::PayMeQuick::App::app[:signature]}")

                Rails::logger::info "Paiement effectué de #{@amount} entre #{@from} et #{@to}."

                #on enregistre encore l'historique
                client_log = History.new(
                    customer_id: client.id,
                    amount: Parametre::Parametre::agis_percentage(@amount),
                    context: "Mobile".upcase,
                    ip: @ip,
                    flag: 'paiement'.upcase,
                    code: @hash
                )

                if client_log.save

                  #fin de journalisation
                  Rails::logger::info "Historique de transaction enregistrée avec succes"

                  #enregistrement des commissions
                  commission = Parametre::Parametre::commission(@hash, @amount, Parametre::Parametre::agis_percentage(@amount).to_f, (Parametre::Parametre::agis_percentage(@amount).to_f - @amount))
                  if commission
                    #fin d'enregistrement de la commission
                    a = {
                        amount: @amount,
                        device: 'XAF',
                        frais: Parametre::Parametre::agis_percentage(@amount).to_f - @amount,
                        total: Parametre::Parametre::agis_percentage(@amount).to_f,
                        receiver: marchand.complete_name,
                        sender: client.complete_name,
                        date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                        status: "DONE"
                    }
                    Rails::logger.info "Transaction response => #{a}"

                    #return true, "Votre Paiement de #{@amount} F CFA vient de s'effectuer avec succes. \t Frais de commission : #{(Parametre::Parametre::agis_percentage(@amount).to_f - @amount).round(2)} F CFA. \t Total prelevé de votre compte : #{Parametre::Parametre::agis_percentage(@amount).to_f.round(2)} F CFA. \t Nouveau solde : #{client_account.amount.round(2)} #{$devise}."
                    return true, {
                        amount: @amount,
                        device: "XAF",
                        frais: (Parametre::Parametre::agis_percentage(@amount).to_f - @amount).round(2),
                        total: (Parametre::Parametre::agis_percentage(@amount).to_f).round(2),
                        receiver: marchand.complete_name,
                        sender: client.complete_name,
                        date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                        status: "DONE"
                    }
                  else
                    Rails::logger.info "Impossible d'entregistrer les commissions de cette transaction"
                  end

                else

                  Rails::logger.info "Impossible d'enregistrer les informations de transation du paiement #{@hash}"

                end
              else
                # raise ActiveRecord::Rollback
                Rails::logger::info "Impossible de crediter le marchand #{marchand.authentication_token} d'un montant de #{@amount} F CFA"
                Sms.sender(marchand.phone, "Impossible de crediter votre compte de #{amount}. Transaction annulee. #{$signature}")
                return false
              end
            else
              Rails::logger::info "Impossible de mettre à jour les informations du client sur la transaction N° #{@hash}, d'un montant de #{@amount} F CFA"
              Sms.sender(client.phone, "Impossible d\n'acceder a votre compte. Transaction annulee. #{$signature}")
              return false
            end
          else
            Rails::logger::info "Le solde du compte client #{client.phone} est insuffisant pour effectuer la transaction de paiement d'un montant de #{@amount}. Paiment impossible"
            return false, {
                title: "SOLDE INSUFFISANT",
                message: "Le solde de votre compte est insuffisant pour effectuer cette transaction! Merci de recharger votre compte!"
            }
          end
        end
      else
        Rails::logger::info "Invalid user password authentication"
        return false, {
            title: "ECHEC IDENTIFICATION",
            message: "Le mot de passe utilisé est invalide, merci de réessayer!"
        }
      end
    end
  end

  # @param [Object] from
  # @param [Object] to
  # @param [Object] amount
  # @param [Object] password
  # @author @mvondoyannick
  # @version 0.0.1beta-rev-11-03-83-50
  # @deprecated
  def self.transfert(from, to, amount, password)
    @from = from
    @to = to
    @amount = amount
    @client_password = password
    if @from == @to
      Sms.new(@from, "Expediteur et Receveur ne peuvent etre identique, merci de changer. #{$signature}")
      Sms::send
      return "#{@from} et #{@to} ne peuvent etre indentique. #{$signature}"
    else
      #on commernce par rechercher si le receveur appartient au reseaux
      marchand = Customer.where(phone: @to).first #personne qui recoit
      marchand_account = Account.where(customer_id: marchand.id).first #le montant de la personne qui recoit
      client = Customer.where(phone: @from).first #la personne qui envoi
      client_account = Account.where(customer_id: client.id) # le montant de la personne qui envoi
      #on authentifie le client a l'aide de son telephone et de son password
      if client.valid_password?(@client_password)
        if client_account.amount >= @amount
          @hash = SecureRandom.hex(13).upcase
          marchand_account.amount = marchand_account.amount + @amount
          if marchand_account.save
            client_account.amount = client_account.amount - @amount

            #on inscrit dans l'historique du marchand
            Journal::Journal::create_logs_transaction(@from, @to, @amount, "credit")
            if client_account.save

              #on inscrit le journal du client concernant sa transaction
              Journal::Journal::create_logs_transaction(@to, @from, @amount, "debit")

              #Envoi des SMS de confirmations de la transaction
              Sms.new(@to, "Le paiement du montant #{@amount} F CFA provenant de #{client.name} #{client.second_name} c est correctement deroule. Votre solde est maintenant de #{marchand_account.amount} F CFA. ID Transaction : #{@hash}. #{$signature}")
              Sms::send
              #----------------------------------
              Sms.new(@from, "#{prettyCallSexe(client.sexe)} #{client.name} #{client.second_name}, #{@amount} F CFA ont ete debite de votre compte, le solde actuel de votre compte est #{client_account.amount} F CFA. ID Transaction : #{@hash}. #{$signature}")
              Sms::send
              return "Le paiement du montant #{@amount} F CFA provenant de #{client.name} #{client.second_name} c est correctement deroule. ID Transaction : #{@hash}. #{$signature}"
            else
              return "Echec du paiement du montant #{@amount} F CFA. Echec de la transaction ID Transaction : #{@hash}. #{$signature}"
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


  #Permet d'enregistrer une transaction de toutes les activités
  # @param [Object] customer
  # @param [Object] code
  # @param [Object] flag
  # @param [Object] context
  # @param [Object] amount
  # @param [Object] ip
  # @param [Object] lat
  # @param [Object] lon
  def self.saveHistory(customer, code, flag, context, amount, ip, lat, lon)
    @customer = customer
    @code = code
    @flag = flag
    @context = context
    @amount = amount
    @ip = ip
    @lat = lat
    @lon = lon

    #on determine la region sur la base de la geolocalisation
    #@region = DistanceMatrix::DistanceMatrix::geocoder_search(@lat, @lon)

    #on initialise le journal de la transaction
    h = History.new(
        # date: Time.now.strftime("%d-%m-%Y @ %H:%M:%S"),
        amount: @amount,
        context: "none",
        customer: @customer,
        flag: @flag,
        code: @code,
        region: nil,
        lat: @lat,
        lon: @lon
    )

    #On demarre l'enregistrement des informations
    h.save
  end

  #Permet de hacher le montant
  def self.hashAmount(amount)
    @amount = amount.to_i

    amountHashed = Digest::MD5.hexdigest(@amount)
    return amountHashed
  end

  #Permet d'effectuer l'abonnement d'un client de type marchand uniquement pour les badges
  # @param [Object] customerId
  # @param [Object] debut
  # @param [Object] type
  # @param [Object] renewAuto
  def self.abonnement(customerId, type, renewAuto)
    @id = customerId #l'utilisateur/marchand concerne
    @begin = Date.today #la date de debut de l'abonnement
    @fin = 30.day.from_now #la date de fin de l'abonnement
    @type = type #le type d'bonnement souscrit

    #on verifie si cet utilisateur existe
    customer = Customer.find(@id)
    if customer.blank?
      return false, "Utilisateur inconnu"
    else
      #on enregistre les informations d'abonnement
    end
    return true, "Utilisateur abonné"
  end

end