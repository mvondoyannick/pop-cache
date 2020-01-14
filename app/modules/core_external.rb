# paiement vers des utilisateurs externe à la plateforme
module CoreExternal

  # manage actions from customer like create account, confirm account, update account, ...
  class Customers

    def self.pay(argv, action, language)
      @phone = argv[:phone]
      @amount = argv[:amount]
      @payer = argv[:payer]


      if customer_exist?(@phone)[0] == true
        # trigger actions for this customer who have activated account
        return true, "Utilisateur existant"
      else

      end
    end

    # check if customer exist
    def self.customer_exist?(argv, action = nil, language = nil)
      @phone = argv[:phone]
      @action = argv[:action]
      @lang = argv[:language]

      if Customer.exists?(phone: @phone)
        @customer = Customer.find_by(phone: @phone)
        if @customer.two_fa == 'activate'
          return true, 'activate'
        elsif @customer.two_fa != 'activate'
          return true, 'not activate'
        end
      else
        return false, "unknow"
      end

    end

    def self.debit_account(argv, action, language)

    end

    def self.credit_account(argv, action, language)

    end

  end

  class Pay

  end
end