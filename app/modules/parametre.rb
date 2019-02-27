module Parametre  
  class Parametre
      require 'jwt'
      $percentage = 2
      $hmac_secret = "my$ecretK3y"

      #retourne le montant majoré du client
      def self.agis_percentage(amount)
          @amount = amount
          tmp = (@amount*$percentage)/100
          converted = @amount + tmp
          puts converted
          return converted.to_i
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