# ALL PARAMETERS APP
# @version 1.0
module Parametre
  
  $key = "Bl@ckberry18"

  class Parametre
      require 'jwt'
      $percentage = 2
      $hmac_secret = Rails.application.secrets.secret_key_base

      #retourne le montant majoré du client (montant avec commission)
      # @param [Integer] amount
      def self.agis_percentage(amount)
          @amount = amount.to_f
          tmp = @amount.to_f * 0.02
          converted = @amount + tmp
          return converted
      end

      #CALCUL DE LA COMMISSION 
      # @param [Object] montant_vente
      def self.setCommission(montant_vente)
        @vente = montant_vente.to_f
        return (@vente * 0.22)
      end

      #CALCUL DU MONTANT A RETIRER
      # @param [Object] montant_vente
      def self.setMontantARetirer(montant_vente)
        @vente = montant_vente.to_f
        return @vente + setCommission(@vente)
      end

      #OBTION DU SOLDE FINAL
      # @param [Object] solde_initial
      # @param [Object] montant_a_retirer
      # @param [Object] montant_vente
      def self.soldeFinale(solde_initial, montant_a_retirer, montant_vente)
        @solde_initial = solde_initial
        @montan
        return @solde_initial

      end

      #SOLDE TEST
      # @param [Object] solde_initial
      # @param [Object] montant_vente
      def self.soldeTest(solde_initial, montant_vente)
        @solde = solde_initial.to_f
        @vente = montant_vente.to_f
        solde = @solde - (@vente * 1.02)
        return solde
      end


      #ENREGISTREMENT DE LA COMMISSION SUR UNE TRANSACTION
      # @param [Object] transaction_id
      # @param [Object] amount
      # @param [Object] total
      # @param [Object] commission
      def self.commission(transaction_id, amount, total, commission)
        #debut de l'enregistrement de la commission sur une transaction
        Rails::logger.info "Enregistrement de la commission de #{commission} sur la transaction N° #{transaction_id} ..."
        query = Commission.new(
          code: transaction_id,
          amount_brut: amount,
          amount_commission: total,
          commission: commission.round(2)
        )

        if query.save
          return true
        else
          return false
        end
      end

      #ENCODAGE JWT
      # @return [Object]
      # @param [Object] chaine
      # def self.encode_jwt(chaine)
      #   Rails::logger::info "Starting encode string as payload ..."
      #   @chaine = chaine
      #   token = JWT.encode @chaine, nil, 'none'
      #   return token
      # end


      #DECODAGE JWT
      ##utilisation de l'algorythme cryptographique HMAC
      # @param [Object] chaine
      # def self.decode_jwt(chaine)
      #   Rails::logger::info "Starting decoding string as payload ..."
      #   @chaine = chaine
      #   token = JWT.decode @chaine, nil, false
      #   #HashWithIndifferentAccess.new token
      #   return token
      # end


      #RETOURN LES INFORMATIONS SUR UN CUSTOMER
      # @param [Object] phone
      def self.get_customer(phone)
        @phone = phone
        query = Customer.where(phone: @phone).first
        if query
          return true, query
        else
          return false
        end
      end

      #INFORMATION DU CONSOMMATEUR
      # @param [Object] id
      def self.get_account(id)
        @customer_id = id
        query = Account.where(customer_id: customer.id).first
        if query
          return true, query
        else
          return false
        end
      end
  end

  class Crypto
    require 'base64'
    require 'aes'

    #CRYPTAGE AES 256
    # @param [Object] chaine
    def self.aesEncode(chaine)
      @chaine = chaine.to_s
      secret = Rails.application.secrets.secret_key_base
      result = AES.encrypt(@chaine, secret)
      return result
    end

    #DECODAGE AES 256 
    # @param [Object] chaineCryptee
    # def self.aesDecode(chaineCryptee)
    #   @chaineCryptee = chaineCryptee
    #   secret = Rails.application.secrets.secret_key_base
    #   result = AES.decrypt(@chaineCryptee, secret)
    #   return result
    # end

    #DECODE EN BASE 64
    # @param [Object] chaine
    # def self.decode(chaine)
    #   @chaine = chaine
    #   result = Base64.decode64(@chaine).to_i
    #   return result
    # end

    #ENCODE EN BASE 64
    # @param [Object] chaine
    def self.encode(chaine)
      @chaine = chaine
      result = Base64.encode64(@chaine)
      return result
    end

    #CRYPTAGE AVEC SSL
    # @param [Object] data
    def self.cryptoSSL(data)
      @otp_sms = data
      digest = OpenSSL::Digest.new('sha1')

      hmac = OpenSSL::HMAC.hexdigest(digest, $key, @otp_sms)
      #=> "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"

      return hmac
    end
  end

  #RECUPERATION DU MOT DE PASSE
  class ForgotPassword
    # recuperation du mot de passe

    def initialize
    end

    #CREATION QUESTION DE SECURITE
    # @param [Object] phone
    # @param [Object] question
    # @param [Object] answer
    def self.resetPassword(phone, question, answer)

    end

    def self.lastCniChar(phone, lastCni)
      #retourne les 3 derniers caracteres de la CNI
      @phone      = phone
      @lastCni    = lastCni
      @customer = Customer.find_by_phone(@phone)
      if @customer.blank?
        Rails::logger::info "Utilisateur inconnu"
        return false
      else
        @cni = @customer.cni.reverse[0..2]
        if @cni.eql?(@lastCni)
          return true, "matched"
        else
          return false, "Impoossible de vous authentifier"
        end
      end
    end

  end


  class CleanAccounts
    # permet de nettoyer les comptes inutiliser

    def initialize
    end

  end

  class PersonalData

    # @param [Object] customer
    # @param [Object] phone
    # @param [Object] phone_sim
    # @param [Object] network_operator
    # @param [Object] uuid
    # @param [Object] imei
    # @param [Object] latitude
    # @param [Object] longitude
    # @param [Object] ip
    def self.setPersonalData(customer, phone, phone_sim, network_operator, uuid, imei, latitude, longitude, ip)
      @customer         = customer
      @phone            = phone
      @phone_sim        = phone_sim
      @network_operator = network_operator
      @uuid             = uuid
      @imei             = imei
      @latitude         = latitude
      @longitude        = longitude
      @ip               = ip

      # on debute l'enregistrement des informations personnelles
      personal = CustomerDatum.new(
        customer:         @customer,
        phone:            @phone,
        phone_sim:        @phone_sim,
        network_operator: @network_operator,
        uuid:             @uuid,
        imei:             @imei,
        latitude:         @latitude,
        longitude:        @longitude,
        customer_ip:      @ip
        )

      if personal.save
        Rails::logger::info "Information peronnelle sauvegardée"
        return true, "Success"
      else
        Rails::logger::info "Impossible de sauvegarder les informations peronnelles"
        return true, "Failed : #{personel.errors.full_messages}"
      end
    end

    # recherche des plages de numeros de telephone
    # @param [Integer] phone
    # @return [Object] string
    def self.numeroOperateurMobile(phone)
      
      orange    = %w(55 56 57 58 59 90 91 92 93 94 95 96 97 98 99)  #tableau des numeros orange
      mtn       = %w(50 51 52 53 54 70 71 72 73 74 75 76 77 78 79)  #tableau des numeros MTN
      nexttel   = %w(60 61 62 63 64 65 66 67 68 69)                 #tableau des numeros nexttel
      camtel    = %w(22 23 24 32 33 34)                             #tableau des numero camtel
      @phone    = phone.to_s

      Rails::logger::info "Starting check network operator for #{@phone}..."

      #On recherche la longueur des numeros de telephones qui doit etre 9 caracteres
      if @phone.length != 9 #> 10 || @phone.length < 9
        return false
      else
        #recherche des numero orange en premier
        @phone_tmp = @phone[1..2]

        # on parcours le tableau
        if @phone_tmp.to_s.in?(orange)
          return "orange"
        elsif @phone_tmp.to_s.in?(mtn)
          return "mtn"
        elsif @phone_tmp.to_s.in?(nexttel)
          return "nexttel"
        elsif @phone_tmp.to_s.in?(camtel)
          return "camtel"
        else
          return "inconnu"
        end
      end
    end


    # recherche des plages de numeros de telephone
    # @param [Integer] phone
    # @return [Object] string
    def self.numeroCameroun(phone)
      orange    = %w(55 56 57 58 59 90 91 92 93 94 95 96 97 98 99)  #tableau des numeros orange
      mtn       = %w(50 51 52 53 54 70 71 72 73 74 75 76 77 78 79)  #tableau des numeros MTN
      nexttel   = %w(60 61 62 63 64 65 66 67 68 69)              #tableau des numeros nexttel
      camtel    = %w(22 23 24)
      @phone    = phone.to_s

      #On recherche la longueur des numeros de telephones qui doit etre 9 caracteres
      if @phone.length != 9
        return false
      else
        #recherche des numero orange en premier
        @phone_tmp = @phone[1..2]

        # on parcours le tableau
        if @phone_tmp.to_s.in?(orange)
          return true
        elsif @phone_tmp.to_s.in?(mtn)
          return true
        elsif @phone_tmp.to_s.in?(nexttel)
          return true
        elsif @phone_tmp.to_s.in?(camtel)
          return true
        else
          return false
        end
      end
    end

    # permet de determiner si c'est un numero du cmr
    def self.cameroun(phone)
      cameroun        = %w(+237 00237 237)
      sous_mobile     = %w(655 656 657 658 659 690 691 692 693 694 695 696 697 698 699 650 651 652 653 654 670 671 672 673 674 675 676 677 678 679 661)
      sous_fixe       = %w()
      @phone          = phone.to_s

      #recherche de la longueur du numero, 9 chiffre pour le cameroun
      if @phone.length > 9
        # on recheche s'il contien le prefixe +237 ou 00237 ou 237
        if @phone.in?(cameroun)
          # on recupere la taille du phone pour savoir exactement ce qu'il faut enlever
          taille = @phone.length
          if taille == 12 # cas du 237
            @phone = @phone.slice(0..2)
            return @phone
          elsif taille == 13 # cas +237
            @phone = @phone.slice(0..3)
            return @phone
          elsif taille == 14 # cas 00237
            @phone = @phone.slice(0..4)
            return @phone
          end
        end
      end

    end


    # Paiement via USSD via Parametre::personalData::payUssd
    def self.payUssd(token, marchand, amount, pasword)
      @client     = token
      @marchand   = marchand
      @amount     = amount.to_f
      @password   = pasword

      # on verifie l'authenticité tu token recu
      customer = Customer.find_by_authenticate_token(@client)
      if customer.blank?
        return false, "Utilisateur inconnu"
      else
        # le customer existe, on cherche egalement a verifier le marchand
        merchant = Customer.find_by_phone(@marchand)
        if merchant.blank?
          return false, "Impossible de trouver le marchand"
        else
          # on connais maintenant le marchand et le client, on peut effectuer les paiements
          # on appel la fonction de paiement
          result = Client.pay(customer.phone, merchant.phone, @amount, @password, "", "", "", "")
          return result
        end
      end
    end
  end

  class SecurityQuestion

    def initialize
    end

    #creatrion d'une question de securité
    # @name
    # @detail
    # @param [Object] customer_id
    # @param [Object] question_id
    # @param [Object] answer
    def self.setSecurityQuestion(customer_id, question_id, answer)
      @customer = customer_id
      @question = question_id
      @answer   = answer

      #on verifie que ce customer existe
      customer = Customer.find(customer_id)
      if customer.blank?
        return false, "Utilisateur inconnu"
      else
        #on debute l'enregistrememnt des informations
        @answer = Answer.new(
          customer_id:  @customer,
          question_id:  @question,
          content:      @answer
        )

        #on effectue l'enregistrement
        if @answer.save
          Rails::logger::info "Information de securité enregistrée"
          return true, "Information de securité enregistrée"
        else
          Rails::logger::info "Impossible d'enregistrer les informations de securité"
          return false, "#{@answer.errors.full_messages}"
        end
      end
    end

    # permet de bloquer un compte client
    # @detail     une fois que l'on demande son mot de passe, le compte se verouiller automatiquement, cas du MDP oublé
    def self.lockCustomerAccount(customer_id)
      @customer = customer_id
      customer = Customer.find(@customer)
      Rails::logger::info "#{customer.two_fa}"
      if customer.blank?
        return false, "Utilisateur inconnu"
      else
        # update two_fa item on customer
        if customer.update(two_fa: "lock")
          return true, "compte bloquer"
        else
          return false, "Impossible de mettre a jour les information de two_fa"
        end
      end
    end


    # debloquer le compte d'un utilisateur
    def self.unlockCustomerAccount(customer_id)
      @customer = customer_id
      customer = Customer.find(@customer)
      if customer.blank?
        return false, "Utilisateur inconnu"
      else
        # tout est bon, on met a jours les informations du two_fa
        if customer.update(two_fa: "authenticate")
          return true, "Utilisateur authentifie"
        else
          return false, "Impossible de mettre a jour les information de two_fa"
        end
      end
    end
  end

  class Authentication

    #permet l'authentification a deux niveau a la creation du compte | One Time Password
    # One Time Password | OTP
    # @params   [object] phone
    # @params   [object] context
    # @return   [object] boolean
    def self.auth_top(phone, context="phone")
      @phone = phone.to_i
      @context = context
      @secret =  ROTP::Base32.random

      #on cherche ce nouvel utilisateur
      # refactory
      if Customer.exists?(phone: @phone)

        #get customer informations
        customer = Customer.find_by_phone(@phone)

        # on genere le code OTP
        @sms_otp = ROTP::TOTP.new(@secret, issuer: "PAYMEQUICK")

        if customer.update(two_fa: @sms_otp.now, perime_two_fa: 1.hours.from_now)
          # send SMS to customer to confirm saving
          Sms.nexah(@phone, "#{@sms_otp.now}")
          return true, "Enregistré"

        else

          # Rollback last record
          # raise ActiveRecord::Rollback
          return false, "Une erreur est survenue"

        end

      else

        return false, "Utilisateur inconnu"

      end

    end

    #permet de valider un code OTP (One Time Password)
    # @params   [object] phone
    # @params   [object] auth_key
    # @return   [object] phone
    def self.validate_otp(phone, auth_key, playerId=nil)
      @phone        = phone
      @otp         = auth_key
      @playerId     = playerId
      puts "Data receive from here : phone => #{@phone}, otp => #{@otp}"
      #on cherche le client responsable de cette demande
      # verification de l'existance de l'utilisateur
      if Customer.exists?(phone: @phone)
        customer = Customer.where(phone: @phone, two_fa: @otp.to_s).first
        if customer &&
          @pwd = ROTP::TOTP.new(ROTP::Base32.random, issuer: "PAYMEQUICK")
          # update customer informations
          customer.two_fa = "authenticate"
          customer.perime_two_fa = "ok"
          customer.password = @pwd.now
          customer.pwd_changed = false
          if customer.save

            #create virtual account
            account = Account.new(
                amount: 0.0,
                customer_id: customer.id
            )

            if account.save

              Sms.nexah(@phone, "Votre identifiant PAYMEQUICK est #{@phone} et votre mot de passe est #{@pwd.now}. Bienvenue!")
              sleep 2
              return true, "created"

            else
              return false, "not created"
            end
          else

            puts "erreurs : #{customer.errors.details}"
            return false, "Impossible de continuer la transaction", customer.errors.details

          end

        else

          return false, "Informations incorrecte"

        end
      else

        return false, "Unitilisateur ou mot de passe inconnu"

      end
    end
  end

  


  #retourne les transaction USSD de la transaction
  class USSD
    def initialize(phone, content)
      @phone = phone
      @content = content
    end

    #permet de generer le code USSD
    def self.generate
    end

    #payer en USSD uniquement
    def self.pay
    end

  end

  # Parametres d'informations de l'utilisateur
  class Profiles

    #CREATE NEW USER PROFILE ON THE PLATEFORM
    # @param [Object] argv
    # @param [String] message
    def self.create(argv, message)
      # Transaction datas
      token = argv[:token]
      amount = argv[:amount]

      # Localisationo Datas
      ip = argv[:ip]
      lat = argv[:latitude]
      long = argv[:longitude]

      #devise datas
      imei = argv[:imei]
      uuid = argv[:uuid]


      date = DateTime.now   # Current date transaction profile
      message = message

      # find customer on the plateforme, raise ActiveRecord::RecordNotFound once failed
      customer = Customer.find_by_authentication_token(token)
      if customer.blank?
        #raise ActiveRecord::RecordNotFound I18n.t("customerNotFound", locale: locale)
        Rails::logger::info "customer not found, no profile!"
        exit(:ok)
      else
        # Find potential existing customer profile
        profile = Profile.find_by(customer_id: customer.id)
        if profile.blank?
          # Not found existing customer profile so we can create new profile information
          new_profile = Profile.new(
            customer_id: customer.id,
            amount: amount,
            ip: ip,
            lat: lat,
            long: long,
          )
        else
          # call method that update profile for customer Data
          update({token: token, amount: amount, ip: ip, lat: lat, long: long, imei: imei, uuid: uuid}, "update customer profile")
        end
      end
      #Get all customer data from transaction


    end


    # Search if profile existe for this user
    # @param [Object] argv
    # @param [String] message
    def self.search(argv, message)

    end

    #UPDATE CUSTOMER PROFILE
    def self.update(argv, message)

    end

    # Read profile content for this customer
    # @param [Object] argv
    # @param [String] message
    def self.read(argv, message)

    end

    # @param [Object] argv
    # @param [String] message
    def self.delete(argv, message)
      
    end

  end

  # Secure customer transaction with secure3d
  class Security

    def initialize()

    end

    # @param [Object] argv
    # @param [Object] message
    def self.secure3d(argv, message)

    end

  end
end