module History    
  class History
    def initialize(marchand, customer, amount, context, flag)
      @marchand = marchand
      @customer = customer
      @amount = amount
      @context = context
      @flag = flag
    end

      def self.get_user_history(phone)
          @phone = phone
          history = Transaction.where(client_phone: @phone).order(created_at: :desc)
          if history
              return history.as_json(only: [:client_phone, :client_name, :amount, :created_at])
          end
      end

      #permet de recherche un utilisateur
      def self.check(customer)
        @customer = customer
        query = Customer.find_by_phone(@customer)
        if query.blank?
          Rails::logger::info "Utilisateurs inconnus #{@customer}"
          return false
        else
          Rails::logger::info "Utilisateurs present sur la plateforme"
          return true
        end
      end

      #permet de creer l'historique des transactions
      def self.history(marchand, customer, amount, context, flag, code_transaction)
        hash = Transaction.new(
          date: Time.now,
          marchand: Customer.where(phone: marchand).first.phone,
          customer: Customer.where(phone: customer).first.phone,
          amount: amount,
          context: context,
          flag: flag,
          code: code_transaction
        )

        #on verifie l'existance des utilisateurs
        if check(@marchand) == true && check(@customer) == true
          if hash.save
            Rails::logger::info "Information journalisée"
            return true
          else
            Rails::logger::info "Impossible de journaliser l'information"
            return false, "Impossible de generer l'historique. Erreur => #{hash.errors.full_messages}"
          end
        else
          #on envoi un mail pour signaler une erreur
          Sms.new(691451189, "Faille dans la base de donnees :: Customer etranger sur la plateforme")
          Sms::send
        end
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