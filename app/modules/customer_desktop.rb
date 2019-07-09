 module CustomerDesktop

  class Client

    def inialize

    end

    def self.signin(email, password)
      Rails::logger.info "Stating login customer desktop ..."
      @phone      = email
      @password   = password

      #on recherche customer
      customer = Customer.find_by_email(@phone)
      if customer.blank?
        return false, "customer not found"
      else
        if customer.valid_password?(@password)
          intend = code_signin(@phone)
          return true, intend[1]
        else
          return false, "Phone or password are wrong"
        end
      end
    end

    #permet de chercher un web customer
    def self.is_customer?(phone)
      @phone      = phone

      customer = Customer.find_by_phone(phone)
      if customer.blank?
        false
      else
        true
      end
    end


    #Permet de generer le code d identification d authentification d'un client web
    # @param [Object] phone
    def self.code_signin(phone)
      @phone      = phone

      @code       = rand(5**5)

      #on enregistre dans la base de données
      customer = Customer.find_by_phone(@phone)
      if customer.blank?
        return false
      else
        #mise a jour du jeton de securité
        if customer.update(two_fa: @code)
          #on genere le SMS
          Sms.new(@phone, "#{@code} est votre code PAYQUICK")
          Sms.send
          return true, customer.as_json(only: :phone)
        else
          return false
        end
      end
    end

    # @param [Object] phone
    # @param [Object] code
    def self.confirm_signin(phone, code)
      @token      = phone
      @code       = code

      puts "le code est #{@code}"

      #on recherche l'utilisateur via son code
      customer = Customer.find_by_phone(@token)
      if customer.blank?
        return false, "Customer not found"
      else
        puts "#{customer.two_fa} est le code"
        if customer.two_fa.eql?(@code.to_s)
          #on met a jour cette information
          if customer.update(two_fa: "authenticate")
            return true, customer.as_json(only: [:name, :second_name, :phone, :email, :authentication_token, :created_at, :cni, :two_fa])
          else
            return false, "Mise a jour impossible"
          end
        else
          return false, "Code pas indentique"
        end
      end

    end

    # @param [Object] token
    def self.history(token)
      @token    = token
      customer = Customer.find_by_authentication_token(@token)
      if customer.blank?
        return false, "Customer not_found"
      else
        transaction = Transaction.where(customer: customer.id).order(created_at: :desc)
        if transaction.blank?
          return false, "Aucune transaction pour le moment"
        else
          return true, transaction.as_json(only: [:id, :created_at, :amount, :context, :customer, :flag, :code, :region, :ip, :color])
        end
      end
    end


    #retourne mes informations sur l'historique en fonction des periodes
    # @param [Object] phone
    # @param [Object] start_date
    # @param [Object] end_date
    def self.history_period(phone, start_date, end_date)
      @phone        = phone
      @start_date   = start_date
      @end_date     = end_date

      if @start_date.is_a?(Date) && @end_date.is_a?(Date)

        #search customer
        customer = Customer.find_by_phone(@phone)
        if customer.blank?
          return false, "Customer not found"
        else
          transaction = Transaction.where(date: @start_date..@end_date).order(date: asc)
          if transaction.blank?
            return false, "Aucune transaction pour cette periode"
          else
            return true, transaction.as_json(only: [:date, :amount, context, :customer, :flag, :code, :region, :ip, :color])
          end
        end

      else
        return false, "Merci de rentrer des formats de date valide"
      end
    end
  end
end