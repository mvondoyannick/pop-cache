module Parametre 
  
  $key = "Bl@ckberry18"

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
          @amount = amount
          tmp = (@amount*$percentage)/100
          converted = @amount + tmp
          puts converted
          return converted.to_f
      end

      
      def self.encode_jwt(chaine)
        @chaine = chaine
        token = JWT.encode @chaine, $hmac_secret, 'HS256'
        return true, token
      end


      #permet de decoder une chaine precedement code avec JWT
      ##utilisation de l'algorythme cryptographique HMAC
      def self.decode_jwt(chaine)
        @chaine = chaine
        token = JWT.decode @chaine, $hmac_secret, true, {algorithm: 'HS256'}
        return true, token[0]
      end


      #retourne les informations du client/customer
      def self.get_customer(phone)
        @phone = phone
        query = Customer.where(phone: @phone).first
        if query
          return true, query
        else
          return false
        end
      end

      #retourne les information du compte d'un utilisateur
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

    #implementation du cryptage via AES
    def self.aesEncode(chaine)
      @chaine = chaine.to_s
      secret = "cb20a3730d9e3f067ed91a6e458da82d"
      result = AES.encrypt(chaine, secret)
      return result
    end

    #implementation du decryptage via AES
    def self.aesDecode(chaineCryptee)
      @chaineCryptee = chaineCryptee
      secret = "cb20a3730d9e3f067ed91a6e458da82d"
      result = AES.decrypt(@chaineCryptee.to_s, secret)
      return result
    end

    def self.decode(chaine)
      @chaine = chaine
      result = Base64.decode64(chaine)
      return result
    end

    def self.encode(chaine)
    end

    def self.cryptoSSL(data)
      @data = data
      digest = OpenSSL::Digest.new('sha1')

      hmac = OpenSSL::HMAC.hexdigest(digest, $key, @data)
      #=> "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"

      return hmac
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
    def self.auth_two_factor(phone, context)
      @phone = phone.to_i
      @context = context

      #on cherche ce nouvel utilisateur
      auth = Customer.where(phone: phone).first

      #on inscrit le nouveau mot de passe dans son compte
      if auth.blank?
        return false, "Aucun utilisateur trouve"
      else
        data = SecureRandom.hex(2).upcase
        #auth.two_fa = Crypto::cryptoSSL(data)
        if auth.update(two_fa: data, perime_two_fa: 1.hour.from_now)
          Sms.new(@phone, "Code Pop Cash : #{data}")
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
    def self.validate_2fa(phone, auth_key)
      @phone = phone
      @auth = auth_key
      #on cherche le client responsable de cette demande
      customer = Customer.where(phone: phone, two_fa: @auth).first
      if customer.blank?
        return false, "Aucun code pour ce numero"
      else
        puts customer.two_fa
        #on verifie que le code auth_key est encore valide dans le temps
        if @auth == customer.two_fa && Time.now <= customer.perime_two_fa
          #on supprimer les information et on les set a authenticate
          if customer.update(two_fa: 'authenticate', perime_two_fa: 'ok')
            Sms.new(@phone, "Mr #{customer.name.upcase}, Votre compte a ete authentifie. Vous pouvez desormais vous connecter.")
            Sms::send
            puts "auth"
            return true, "Authenticated & updated"
          else
            puts "Failed auth"
            return false, "update failed"
          end
          return true, "Authenticated"
        else
          puts "verification impossible"
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