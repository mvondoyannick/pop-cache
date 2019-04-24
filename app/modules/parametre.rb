module Parametre 
  
  $key = "Bl@ckberry18"

  # @param [Object] data
  def self.tested(data)
      result = data.to_s
      return result
  end

  class Parametre
      require 'jwt'
      $percentage = 2
      $hmac_secret = Rails.application.secrets.secret_key_base

      #retourne le montant majoré du client
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


      #permet d'enregistrer les commissions pour une transaction
      # @param [Object] code
      # @param [Object] amount
      # @param [Object] total
      # @param [Object] commission
      def self.commission(code, amount, total, commission)
        #debut de l'enregistrement
        query = Commission.new(
          code: code,
          amount_brut: amount,
          amount_commission: total,
          commission: commission
        )

        if query.save
          return true
        else
          return false, query.errors.full_messages
        end


      end

      #ENCODAGE JWT
      # @return [Object]
      # @param [Object] chaine
      def self.encode_jwt(chaine)
        Rails::logger::info "Starting encode string as payload ..."
        @chaine = chaine
        token = JWT.encode @chaine, nil, 'none'
        return token
      end


      #DECODAGE JWT
      ##utilisation de l'algorythme cryptographique HMAC
      # @param [Object] chaine
      def self.decode_jwt(chaine)
        Rails::logger::info "Starting decoding string as payload ..."
        @chaine = chaine
        token = JWT.decode @chaine, nil, false
        #HashWithIndifferentAccess.new token
        return token
      end


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
    def self.aesDecode(chaineCryptee)
      @chaineCryptee = chaineCryptee
      secret = Rails.application.secrets.secret_key_base
      result = AES.decrypt(@chaineCryptee, secret)
      return result
    end

    #DECODE EN BASE 64
    # @param [Object] chaine
    def self.decode(chaine)
      @chaine = chaine
      result = Base64.decode64(@chaine).to_i
      return result
    end

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
      @data = data
      digest = OpenSSL::Digest.new('sha1')

      hmac = OpenSSL::HMAC.hexdigest(digest, $key, @data)
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

    # permet de retourner l'historique des activités d'un customer, marchand ou pas!
    # @param [Object] id
    # @param [Object] transaction_id
    # @param [Object] amount
    # @param [Object] context
    def self.getHistorique(id, transaction_id, amount, context)
      @customer_id      = id
      @transaction_id   = transaction_id
      @amount           = amount.to_i
      @context          = context     # permet de savoir si c'est un debit ou un credit

      # creation de l'objet transaction
      transaction = Transaction.new(
        date:     Time.now,
        amount:   @amount,
        context:  @context,
        customer: Customer.find(@customer).authentication_token,
        flag:     "Flag",
        code:     @transaction_id
      )

      if transaction.save
        return true, "Logs saved"
      else
        return false, "Impossible de sauver les logs"
      end
    end

    # recherche des plages de numeros de telephone
    # @param [Object] phone
    # @return [Object] string
    def self.numeroOperateurMobile(phone)
      orange    = %w(55 56 57 58 59 90 91 92 93 94 95 96 97 98 99)  #tableau des numeros orange
      mtn       = %w(50 51 52 53 54 70 71 72 73 74 75 76 77 78 79)  #tableau des numeros MTN
      nexttel   = %w(61)              #tableau des numeros nexttel
      @phone    = phone.to_s

      #recherche des numero orange en premier
      @phone_tmp = @phone[1..2]

      # on parcours le tableau
      if @phone_tmp.to_s.in?(orange)
        return "orange"
      elsif @phone_tmp.to_s.in?(mtn)
        return "mtn"
      elsif @phone_tmp.to_s.in?(nexttel)
        return "nexttel"
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
          result = Client.pay(customer.phone, merchant.phone, @amount, @password)
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
    # @params customer_id:interger, question_id:interger, answer:string
    # @return 
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

  class Bank

    def self.new
    end

    #supprimer une banque de la plateforme
    def self.delete
    end

    #obtenir la liste des banque
    def self.get
    end

    def self.list
    end
  end

  class Authentication
    #permet l'authentification a deux niveau a la creation du compte
    #pour s'assurer que le client
    # @params   [object] phone
    # @params   [object] context
    # @return   [object] boolean
    def self.auth_two_factor(phone, context)
      @phone = phone.to_i
      @context = context

      #on cherche ce nouvel utilisateur
      auth = Customer.find_by_phone(phone)

      #on inscrit le nouveau mot de passe dans son compte
      if auth.blank?
        return false, "Aucun utilisateur trouve"
      else
        @data = rand(6**6) #SecureRandom.hex(2).upcase
        #auth.two_fa = Crypto::cryptoSSL(data)
        if auth.update(two_fa: @data, perime_two_fa: 1.hour.from_now)
          Sms.new(@phone, "Votre Code authentification POPCASH : #{@data}")
          Sms::send

          #on retourne les informations
          return true, "Identification a deux facteurs envoyé"
        else
          Sms.new(@phone, "Impossible de terminer votre inscription .")
          Sms::send

          #on retourne les informations
          return false, "Echec Identification a deux facteurs, errors: #{auth.errors.messages}"
        end 
      end
    end

    #permet de valider un code 2fa
    # @params   [object] phone
    # @params   [object] auth_key
    # @return   [object] phone
    def self.validate_2fa(phone, auth_key)
      @phone = phone
      @auth = auth_key.to_i
      #on cherche le client responsable de cette demande
      @customer = Customer.where(phone: @phone, two_fa: @auth).first
      if @customer.blank?
        Rails::logger::info "Utilisateur inconnu"
        return false, "Aucun code pour ce numero"
      else
        Rails::logger::info "le code d'authentification actuel est #{@customer.two_fa}"
        #on verifie que le code auth_key est encore valide dans le temps
        if  @customer.two_fa.to_i.eql?(@auth)
          if Time.now <= @customer.perime_two_fa
            # si le code d'authentication n'est pas encore peripé
            #on supprimer les information et on les set a authenticate
            if @customer.update(two_fa: 'authenticate', perime_two_fa: 'ok')
              Sms.new(@phone, "Mr #{@customer.name.upcase}, Votre compte a ete authentifie. Vous pouvez desormais vous connecter.")
              Sms::send

              Rails::logger::info  "#{@phone} vient d'etre authentifier sur POPCASH a #{Time.now}"

              # creation du compte "porte monnaie virtuel"

              virtual_account = Client::create_user_account(@phone)
              if virtual_account[0] == true
                Rails::logger::info  "#{@phone} dispose desormais d'un compte virtuel actif sur POPCASH a #{Time.now}"
                return true, "#{@phone} est Authenticated & dispose d'un compte virtuel actif"
              else
                Rails::logger::info  "Echech de creation du compte #{@phone} sur POPCASH a #{Time.now}"
                return virtual_account[0], virtual_account[1]
              end

              # fin de la creation virtuelle
            else
              Rails::logger::info "Impossible d'authentifier cet utilisateur : #{@phone}"


              return false, "unauthenticable"
            end
          else
            Rails::logger::info "Code d'authentification perimé, merci de reprendre la procedure d'authentification."
            return false, "Code d'authentification perimé, merci de reprendre la procedure d'authentification."
          end
          #return true, "Authenticated"
        else
          Rails::logger::info "verification du code #{@auth} impossible pour le numéro #{@phone}"
          return false, "Authentification Impossible : Date ou code incorrect"
        end
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
end