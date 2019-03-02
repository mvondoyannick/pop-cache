module History    
  class History
      def initialize
          
      end

      def self.get_user_history(phone)
          @phone = phone
          history = Transaction.where(client_phone: @phone).order(created_at: :desc)
          if history
              return history.as_json(only: [:client_phone, :client_name, :amount, :created_at])
          end
      end


      #permet de faire l'historique des depots dans une agence
      def self.depot
      end

      #permet de faire l'historique des retrait sans une agence
      def self.retrait
      end

      #permet de faire l'historique des payments entre clients
      # @param phone
      # @route /history/h/payment
      # @method post
      def self.payment(phone)
          @phone = phone.to_i
          customer = CustomerClient::Client::get_customer(@phone)
          if customer[0] == false
              return false, customer[1]
          else
              query = Transaction.where(phone: @phone, context: "debit")
              if query.blank?
                  return false, "Aucune historique trouve"
              else
                  return true, query
              end
          end
      end

      #permet de faire l'historique des encaissement entre clients
      # @param phone
      # @route /history/h/encaisser
      # @method post
      def self.encaisser(phone)
        @phone = phone.to_i
        customer = CustomerClient::Client::get_customer(@phone)
          if customer[0] == false
              return false, customer[1]
          else
              query = Transaction.where(phone: @phone, context: "credit")
              if query.blank?
                  return false, "Aucune historique trouve"
              else
                  return true, query
              end
          end

      end
  end
end