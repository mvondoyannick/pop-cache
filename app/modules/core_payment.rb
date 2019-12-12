# module de gestion des transactions de paiement
module CorePayment

  class Payment

    def initialize(argv, intent, lang)

    end

    # pay transaction
    # @author mvondoyannick
    # @param [Object] argv
    # @param [String] intent
    # @param [String] lang
    def self.Pay(argv, intent, lang)

      @argv = argv
      puts self

      # payer datas
      @payer = argv[:payer] #authentication_token
      @payer_password = argv[:password]
      @transaction_amount = argv[:amount]

      # merchant datas
      @merchant = argv[:merchant]

      @intent = intent
      @lang = lang

      # searching payer informations
      user = Customer.exists?(authentication_token: @payer)
      if user
        # authenticate customer on API plateform
        customer = Customer.find_by(authentication_token: @payer, two_fa: "authenticate")
        if customer & customer.valid_password?(@payer_password)
          # did customer have enought amount in his account?
          if customer_has_amount?(customer, @transaction_amount)

          else

            return false, "Vous n'avez pas d'argent dans votre compte"
            
          end
        else
          # password mismatch
          return false, "Impossible d'effectuer la transaction"
        end
      else
        # payer not found
        return false, "Utilisateur inconnu"
      end

    end

    # customer/payer has amount?
    # @param [Object] customer
    # @param [Integer] transaction_amount
    def self.customer_has_amount?(customer, transaction_amount)

      @customer = customer
      @transaction_amount = transaction_amount

      if @customer.account.amount >= @transaction_amount.to_f
        return true
      else
        return false
      end

    end

    # Customer and merchant must to have different phone
    # @param [Object] customer
    # @param [Integer] merchant
    def self.different_phones?(customer, merchant)

      @customer = customer
      @merchant_phone = merchant

      if @customer.phone == @merchant_phone
        puts "Customer phone is the same than merchant"
        return false
      else
        puts "Customer phone is different from merchant"
        return true
      end
    end

  end

end