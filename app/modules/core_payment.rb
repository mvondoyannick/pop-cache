# module de gestion des transactions de paiement
# @name CorePayment
module CorePayment

  class Payment

    # pay transaction
    # @author mvondoyannick
    # @param [Object] argv
    # @param [String] intent
    # @param [String] lang
    def self.makePayment(argv, intent, lang)

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

    # Get à payment from payer
    # @param [Object] argv
    # @param [String] intent
    # @param [String] langue
    def self.getPayment(argv, intent, langue = nil)

      @langue = langue
      @intent = intent
      @argv = argv

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

  class Sos

    # generate SOS link
    # @param [String] intent
    # @param [String] lang
    def self.generate_sos(argv, intent = nil, lang = nil)
      @amount = argv[:amount].to_f
      @password = argv[:password]
      @phone = argv[:phone].to_i
      @motif = argv[:motif]
      @intent = intent
      @lang = lang

      if @amount < 1000 # on ne peut pas faire des demande SOS de moins de 1000
        return false, "Montant en dessous du montant autorisé"
      else
        # search customer
        @customer = Customer.find_by(phone: @phone)

        @code = Faker::Internet.password(min_length: 10, max_length: 20)

        # create new record SOS
        @sos = So.new(
            montant: @amount,
            delais: 2.days.from_now,
            code: @code,
            use: false,
            customer_id: @customer.id
        )

        if @sos.save

          return "https://www.paiemequick.com/sos/#{@sos.code}"

        else

          return false, "Impossible de generer un code : #{@sos.errors.messages.details}"
        end
      end
    end

    #Liste all SOS generate by a customer via his ID
    # @param [Object] argv
    # @param [String] intent
    def self.list_sos(argv, intent = nil, lang = nil)
      @customer = argv[:customer]   # customer_id
      @intent = intent  #Intention en cours de réalisation
      @lang = lang      #Langage de l'intention de la requete

      @list = Customer.find(@customer).so
      if @list.nil?
        return false, "Aucune(s) demande de SOS trouvée"
      else
        return true, @list.as_json(only: [:montant, :created_at, :delais, :code, :close])
      end
    end

    # pay SOS by user, unless with his account
    # @param [String] intent
    # @param [Object] argv
    # @param [String] lang
    def self.pay_sos(argv, intent = nil, lang = nil)

      @customer = argv[:customer]   # customer_id
      @montant = argv[:montant]
      @code = argv[:code]
      @pret = argv[:pret]
      @lang = lang
      @intent = intent

      # begining search pret code
      @sos_order = So.find_by(code: @code)
      if @sos_order.nil?
        return false, "Aucune demande de payment trouvé à ce code"
      else
        # Check validity on payment date
        if @sos_order.delais.to_datetime < DateTime.now
          return false, "Le paiement de cette demande d'aide de paiement est périmé"
        else
          # check if payment amount is upper than defined amount
          if @sos_order.montant < @amount.to_f
            return false, "Vous ne pouvez pas payer aud-ela de la demande du client"
          else
            # on verify que le nouveau montant ne depasse pas le montant de depart
            # montant
            if @sos_order.close == true
              #reject new payment
              return false, "Ce paiement est deja complet et actuellement cloturé"
            else
              # le paiement est encore ouvert, on peut encore recevoir des paiements
              @total_amount_for_sos_payment = So.find(@sos_order.id).sospayment.sum(:amount)
              if @total_amount_for_sos_payment + @montant.to_f > @sos_order.montant.to_f
                # la somme du dernier paiement est superieur au montant demandé

                # calcul du reste à payer
                reste = @sos_order.montant.to_f - @total_amount_for_sos_payment.to_f

                return true, "Le montant de #{@montant} CFA semble etre superieur à la somme des paiements deja recu par le demandeur. Merci de revoir votre montant à la baisse. Vous pouvez maintenant lui envoyer un maximum de #{reste}"
              else
                #debit sender account before
                debit = debit_customer_account(customer: @customer, amount: @amount)
                if debit[0]
                  # valid all paiements trigger actions, update DB
                  @new_sos_payment = Sospayment.new(
                      amount: @montant.to_f,
                      payer: @customer,
                      payment_date: DateTime.now,
                      pret: @pret,
                      so_id: @sos_order.id
                  )

                  if @new_sos_payment.save
                    #send Notifications to demander
                    Sms.nexah(Customer.find(@sos_order.customer_id).phone, "Nouvelle reponse à votre aide de paiement recu d'un montant de #{@montant.to_f} CFA par #{Customer.find(@customer).complete_name}")
                    sleep 2
                    # engager l'historique
                    #
                    # Check and sum all sub payment
                    if So.find(@sos_order.id).sospayment.sum(:amount).to_f.round(0) == So.find(@sos_order.id).montant.to_f.round(0)
                      if So.find(@sos_order.id).update(close: true)
                        Sms.nexah(Customer.find(@sos_order.customer_id).phone, "Votre paiement de #{@sos_order.montant} CFA est cloturé. Merci d'avoir utilisé PAYMEQUICK")
                        sleep 2
                        return true, "Ce paiement est définitivement cloturé"
                      else
                        return false, "Impossible de cloturer ce paiement, une alerte est lancée!"
                      end
                    end
                    # repondre au client
                    return true, "Paiement enregistré"
                  else
                    return false, "Impossible d'effectuer ce paiement : #{@new_sos_payment.errors.details}"
                  end
                else
                  return false, debit[1]
                end
              end
            end
          end
        end
      end
    end


    def self.debit_customer_account(argv, intent = nil, lang = nil)
      @customer = argv[:customer] #customer_id
      @amount = argv[:amount] #amount to debit

      puts "Calling debit sender account with id #{rand(10**10)}"

      # search customer
      if Customer.exists?(id: @customer)
        customers = Customer.find(@customer)

        #verifie s'il a suffisament de fond dans son compte
        if customers.account.amount > @amount.to_f
          if customers.account.update(amount: (customers.account.amount - @amount.to_f))
            #trigger history
            # sending SMS
            Sms.nexah(customers.phone, "Debit de votre compte PAYMEQUICK d'une valeur de #{@amount} CFA pour aide à une demande de paiement. ")
            # respond to client
            return true, "Debit effectué"
          else
            return false, "Impossible d'effectuer le debit du compte"
          end
        else
          return false, "Solde insuffisant dans le compte, transaction annulée"
        end

      else
        return false, "Utilisateur ou compte inexistant"
      end

    end

    # list or detail of one SOS request for payment help
    def self.detail_sos(argv, intent = nil, lang = nil)
      @customer = argv[:customer]   # customer_id
      @sos_id = argv[:sos]  # sos_code
      @intent = intent # intention name
      @lang = lang  # language name

      @detail = Customer.find(@customer).so.find_by(code: @sos_id).sospayment
      if @detail.nil?
        return false, "ceci est genant mais aucun contenu n'a été trouvé"
      else
        return true, @detail.as_json(only: [:amount, :payment_date, :pret, :payer])
      end
    end

  end

end