# Return all history transaction from customer or enterprise
module Logstory
  class Histo
    def initialize(marchand, customer, amount, context, flag)
      @marchand = marchand
      @customer = customer
      @amount = amount
      @context = context
      @flag = flag
    end
  
    #Historique journalier d'un customer
    # @param [String] token
    # @param [String] period
    def self.h_customer(token, period)
      @token      = token
      @period     = period

      begin

        Rails::logger.info "Starting request"
        @customer = Customer.find_by_authentication_token(@token) # obtention des informations sur le customer

        #Search customer
        if @customer
          case @period
          when "jour"
            Rails::logger.info "Recherche des transactions journalieres ..."
            @h = History.where(customer_id: @customer.id).where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).order(created_at: :desc).last(100).as_json(only: [:created_at.strftime("%d-%m-%Y, %H:%M:%S"), :amount, :flag, :code, :color, :region])
            if @h.blank?
              return false, "Aucune transaction pour ce jour."
            else
              return true, @h
            end
          when "semaine"
            Rails::logger.info "Recherche des informations hebdomadaire ..."
            @h = History.where(customer_id: @customer.id).where(created_at: Date.today.beginning_of_week..Date.today.end_of_week).order(created_at: :desc).last(100).as_json(only: [:created_at.strftime("%d-%m-%Y, %H:%M:%S"), :amount, :flag, :code, :color, :region])
            if @h.blank?
              return false, "Aucune transaction pour cette semaine."
            else
              return true, @h
            end
          when "mois"
            Rails::logger.info "Recherche des informations mensuelles ..."
            @h = History.where(customer_id: @customer.id).where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc).last(100).as_json(only: [:created_at.strftime("%d-%m-%Y, %H:%M:%S"), :amount, :flag, :code, :color, :region])
            if @h.blank?
              return false, "Aucune transaction pour ce mois."
            else
              return true, @h
            end
          when "all"
            Rails::logger.info "Recherche de toutes les informations depuis le debut de l'inscription de l'utiliateur ..."
            @h = History.where(customer_id: @customer.id).all.order(created_at: :desc).as_json(only: [:created_at.strftime("%d-%m-%Y, %H:%M:%S"), :amount, :flag, :code, :color, :region])
            if @h.blank?
              return false, "Aucune transaction enregistrée depuis la creation de votre compte"
            else
              return true, @h
            end
          when "annee"
            Rails::logger.info "Recherche des informations annuelles ..."
            @h = History.where(customer_id: @customer.id).where(created_at: Date.today.beginning_of_year..Date.today.end_of_year).order(created_at: :desc).last(100).reverse.as_json(only: [:created_at.strftime("%d-%m-%Y, %H:%M:%S"), :amount, :flag, :code, :color, :region])
            if @h.blank?
              return false, "Aucune transaction pour cette année."
            else
              return true, @h
            end
          else
            Rails::logger.info "Recherche des informations sans periode ..."
            customer = Customer.find_by_authentication_token(@token) # obtention des informations sur le customer
            Rails::logger::info "Customer id is : #{customer.id}"
            @h = History.where(customer_id: customer.id).order(created_at: :asc).last(30).reverse.as_json(only: [:created_at.strftime("%d-%m-%Y, %H:%M:%S"), :amount, :flag, :code, :color, :region])
            #@h = Customer.find_by_authentication_token(@token).history  #History.where(customer: @customer[1]["id"]).order(created_at: :asc).last(30).reverse.as_json(only: [:date, :amount, :flag, :code, :color, :region])
            if @h.blank?
              return false, "Il semble que vous n'ayez encore effectué aucune transaction."
            else
              return true, @h
            end
            #return false, "Nous ne sommes pas en mesure de comprendre cette Période "
          end
        else
          return "Customer unknow"
        end


      rescue ActiveRecord::ConnectionNotEstablished

        return false, "Un probleme de connexion est survenu"

      end
    end



    # Get history with beginning and end period
    # @calling Lostory::Histo.h_interval(token: @token, debut: @debut, fin: @fin)
    # @param [Object] argv
    def self.h_interval(argv)

      @token    = argv[:token]
      @debut    = argv[:begin]
      @fin      = argv[:end]

      begin

        #chech user token
        customer = Customer.find_by_authentication_token(@token)
        if customer.blank?

          return false, "CUSTOMER NOT FOUND", status: 404

        else

          Rails::logger.info customer.phone
          query = History.where(customer: customer.id).where(created_at: @debut.to_date..@fin.to_date).order(created_at: :desc).last(100).reverse.as_json(only: [:date, :amount, :flag, :code, :color, :region])
          if query.blank?

            return false, "Aucune transaction effectuée entre #{@debut} et #{@fin}"

          else

            return true, query

          end

        end  

      rescue ActiveRecord::RecordNotFound

        return false, "CUSTOMER NOT FOUND"

      end
      

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
          if !customer[0]
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
          if !customer[0]
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