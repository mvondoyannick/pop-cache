module Entreprise

    class Entreprise

      #NIU = Numero d'indentification unique  
      def self.create_entreprise(name, niu, registre, phone, email)

          return true
        end


        def self.get_entreprise(pin)

          return result
        end

        #retourne une entreprise si elle existe
        def self.get_entreprise_account

        end

    end


    class Manage

      #suspend une entreprise
      def self.suspend(pin, motif)
      end

      #relache une entreprise suspendu
      def self.release(pin, motif)
      end

    end


    #permet d'envoyer les SMS entreprise
    class Sms

      def initialize(phone, message)
        
      end

      #envoyer le message uniquement si c'est une entreprise
      def seld.send(pin)
      end
    end
    
end