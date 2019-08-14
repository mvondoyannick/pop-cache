module PayMeQuick

  Rails.logger = Logger.new(Rails.root.join('log', 'payment.log'))

    class Payment

      #VERIFY IF MERCHANT CAN RECEIVE PAYMENT TRANSACTION
      # @param [Object] argv
      # @param [String] message
      # @return [Boolean] true/false
      def self.merchant_can_receive?(argv, message=nil)
        merchant = argv[:merchant]
        amount = argv[:amount]
        message = message

        @merchant = Customer.find_by(authentication_token: merchant, two_fa: 'authenticate')
        if @merchant.blank?
          Rails::logger.error "Merchant Token #{merchant} canot be found : CustomerNotFound"
          return false
        else
          return true
        end
      end

      #CHECK IF CUSTOMER HAS MONEY TO DO TRANSACTION
      # @param [String] customer
      # @param [String] amount
      # @param [String] message
      def self.customer_has_money_for_transaction?(customer, amount, message=nil)
        customer = customer
        amount = amount.to_f
        message = message

        begin

          # get customer Data
          @customer = Customer.find_by_authentication_token(customer)
          if @customer.account.amount >= amount
            return true # customer have amount, we can do transaction
          else
            return false # he don't have enough amount, cancel transaction
          end

          rescue ActiveRecord::RecordNotFound
            return false

          rescue NoMethodError => e
              return false

        end

      end

      #CHECK IF MERCHANT HAS REACHED MONTHLY TRANSACTION COUNT LIMIT
      # @param [String] merchant
      # @param [String] message
      # @return [Boolean] True/false
      def self.demo_merchant_reached_monthly_transaction_count_limit?(merchant, message=nil)
        merchant = merchant
        message = message

        begin

          #search in History and sum transaction for this day
          @merchant = Customer.find_by_authentication_token(merchant)
          @transactions = History.where(customer_id: @merchant.id, created_at: Date.today.beginning_of_month..Date.today.end_of_month).count
          if @transactions > App::PayMeQuick::App.limit[:limit_month_transaction]
            Rails::logger.info "Limit de transaction journaliere deja dépassée"
            return true  # A deja dépassé la limite de transaction mensuelle
          else
            Rails::logger.info "Limit de transaction journaliere pas encore dépassée"
            return false # Pas  encore dépassé la limite de transaction mensuelle
          end
          
        rescue => exception
          Sms.sender(691451189, "Exeption reached : #{exception}, from #{self.class.name}. customer ID : #{merchant}")
          return false
        end

      end

      #CHECK IF MERCHANT HAS REACHED DALY TRANSACTION COUNT LIMIT
      # @param [String] merchant
      # @param [String] message
      # @return [Boolean] True/false
      def self.demo_merchant_reached_dayly_transaction_count_limit?(merchant, message=nil)
        merchant = merchant
        message = message

        begin

          #search in History and sum transaction for this day
          @merchant = Customer.find_by_authentication_token(merchant)
          @transactions = History.where(customer_id: @merchant.id, created_at: Date.today.beginning_of_day..Date.today.end_of_day).count
          if @transactions > App::PayMeQuick::App.limit[:limit_day_transaction]
            Rails::logger.warn "Limit de transaction journaliere deja dépassée"
            return true  # A deja dépassé la limite de transaction journaliere
          else
            Rails::logger.warn "Limit de transaction journaliere pas encore dépassée"
            return false # Pas  encore dépassé la limite de transaction jorunaliere
          end
          
        rescue => exception
          
          Sms.sender(691451189, "Exeption reached : #{exception}, from #{self.class.name}. customer ID : #{merchant}")
          return false
        end

      end

      #CHECK IF DEMO MERCHANT HAS REACHED MONTHLY AMOUNT LIMIT
      # @param [String] merchant
      # @param [String] message
      # @return [Boolean] True/false
      def self.demo_merchant_reached_monthly_amount_limit?(merchant, message=nil)
        merchant = merchant
        message = message

        begin

          #search in History and sum transaction for this day
          @merchant = Customer.find_by_authentication_token(merchant)
          @transactions = History.where(customer_id: @merchant.id, created_at: Date.today.beginning_of_month..Date.today.end_of_month).sum(:amount)
          if @transactions >= App::PayMeQuick::App.limit[:limit_account_amount_month] #300000 F
            Rails::logger.warn "Limit du montant de transaction mensuel deja dépassé"
            return true  # A deja dépassé la limite de transaction journaliere
          else
            Rails::logger.warn "Limit du montant de transaction mensuel pas encore dépassé"
            return false # Pas  encore dépassé la limite de transaction jorunaliere
          end
          
        rescue => exception

          Sms.sender(691451189, "Exeption reached : #{exception}, from #{self.class.name}. customer ID : #{merchant}")
          return false
          
        end

      end

      #CHECK IF DEMO MERCHANT HAS REACHED DAYLY AMOUNT LIMIT
      # @param [String] merchant
      # @param [String] message
      # @return [Boolean] True/false
      def self.demo_merchant_reached_daily_amount_limit?(merchant, message=nil)
        merchant = merchant
        message = message

        begin

          #search in History and sum transaction for this day
          @merchant = Customer.find_by_authentication_token(merchant)
          @transactions = History.where(customer_id: @merchant.id, created_at: Date.today.beginning_of_day..Date.today.end_of_day).sum(:amount)
          if @transactions >= App::PayMeQuick::App.limit[:limit_account_amount_month] #10000 F
            Rails::logger.warn "Limit du montant de transaction journalier deja dépassé"
            return true  # A deja dépassé la limite de transaction journaliere
          else
            Rails::logger.warn "Limit du montant de transaction journaliere pas encore dépassé"
            return false # Pas  encore dépassé la limite de transaction jorunaliere
          end
          
        rescue => exception

          Sms.sender(691451189, "Exeption reached : #{exception}, from #{self.class.name}. customer ID : #{merchant}")
          return false
          
        end

      end

      #CHECK IF MERCHANT IS A DEMO ACCOUNT, ACCOUNT WITH TYPE ID=2
      # @param [String] merchant
      # @param [String] message
      # @return [Boolean] True/false
      def self.merchant_is_demo_user?(merchant, message=nil)
        merchant = merchant
        message = message

        begin

          if Customer.exists?(authentication_token: merchant)

            @merchant = Customer.find_by_authentication_token(merchant)
            if @merchant.type.name == "demo"
              return true
            else
              return false
            end

          else
            return false
          end
          
        rescue => exception

          Sms.sender(691451189, "Exeption reached : #{exception}, from #{self.class.name}. customer ID : #{merchant}")
          return false
          
        end

      end

      #VERIFY IF CUSTOMER CAN PAY A TRANSACTION
      # @param [Object] argv
      # @param [String] message
      # @todo I have to verify customer account
      def self.customer_can_pay?(argv, message=nil )
        customer = argv[:customer]
        amount = argv[:amount]
        message = message

        # searching if that customer is not lock
        @customer = Customer.find_by(authentication_token: customer, two_fa: 'authenticate')
        if @customer.blank?
          return false
        else
          if @customer.account.amount >= amount
            return true
          else
            return false
          end
        end
      end

      # @param [Object] argv
      # @param [String] message
      # @param [String] locale
      def self.payment(argv, message=nil, locale="en")
        customer = argv[:customer]
        merchant = argv[:merchant]
        amount = argv[:amount]
        password = argv[:password]
        ip = argv[:ip]
        lat = argv[:lat]
        lon = argv[:lon]

        # extra parameters
        message = message
        locale = locale
        code = "PAY_#{SecureRandom.uuid}"

        # check difference if customer is different from merchant
        if customer == merchant
          Rails::logger.error "Le customer #{customer} et le merchant #{merchant} sont indentiques, transaction annulée ..."
          return false, {
              title: I18n.t("errMerchantTitle", locale: locale),
              message: I18n.t("errMerchantContent", locale: locale),
              ray: SecureRandom.uuid
          }
        else
          # verify if limits do not reach
          if amount > App::PayMeQuick::App.limit[:limit_amount]
            Rails::logger.error "Limite maximal de paiement atteinte, le montant de #{amount} F CFA est superieur a la limite maximale, transaction annulée ..."
            return false, {
                title: I18n.t("transactionLimitTitle", locale: locale),
                message: I18n.t("transactionLimitContent", locale: locale)
            }
          else
            # Queriying customer information from AR
            @customer = Customer.find_by_authentication_token(customer)
            @merchant = Customer.find_by_authentication_token(merchant)

            # Searching if merchant have a demo account
            if merchant_is_demo_user?(merchant)
              #Check the sum of the amount of his account for this day and this mount
              # to see if he has no reach dayly limit and montly limit

              # s'il n'a pas encore depassé le nombre de transaction journaliere
              # qui lui est autorisé!
              if demo_merchant_reached_dayly_transaction_count_limit?(merchant)
                Rails::logger.warn "Limite de transaction atteint pas le marchand, transaction annulée"

                # Send Sms to merchant
                Sms.sender@merchant.phone, "Votre LIMITE de transaction journaliere a ete atteinte, merci de creer un compte pour beneficier des paiements sans limite. #{App::PayMeQuick::App.app[:signature]}"
                return false, {
                    title: "Echec transaction",
                    message: "Ce marchant ne peut plus effectuer une transaction, il a atteint son quota journalier de transaction"
                }
              else
                # Il n'a pas encore atteint sa limite de 100 paiements par jour,
                # verifions s'il a atteint le montant de paiement journalier
                if demo_merchant_reached_daily_amount_limit?(merchant)
                  Rails::logger.warn "Limite du montant de la transaction maximal journaliere atteinte, transaction annulée"

                  # Send Sms to merchant
                  Sms.sender@merchant.phone, "Votre LIMITE de transaction journaliere a ete atteinte! merci de creer un compte pour beneficier des paiements sans limite. #{App::PayMeQuick::App.app[:signature]}"
                  return false, {
                      title: "Echec transaction",
                      message: "Ce marchant ne peut plus effectuer une transaction, il a atteint son quota journalier de transaction"
                  }
                else
                  # verification de la limite mensuelle du nombre de transaction du marchand
                  # ce plafond n'a pas encore été atteint, on peut continuer a verifier pour les mois
                  if demo_merchant_reached_monthly_transaction_count_limit?(merchant)
                    Rails::logger.warn "Limite de transaction mensuelle atteint pas le marchand, transaction annulée"

                    # Send Sms to merchant
                    Sms.sender@merchant.phone, "Votre LIMITE de transaction mensuelle a ete atteinte, merci de creer un compte pour beneficier des paiements sans limite. #{App::PayMeQuick::App.app[:signature]}"
                    return false, {
                        title: "Echec transaction",
                        message: "Ce marchant ne peut plus effectuer une transaction, il a atteint son quota journalier de transaction"
                    }
                  else
                    # verification de la limite mensuelle de paiement du marchand
                    if demo_merchant_reached_monthly_amount_limit?(merchant)
                      Rails::logger.warn "Limite de transaction mensuel du montant max atteint pas le marchand, transaction annulée"

                      # Send Sms to merchant
                      Sms.sender@merchant.phone, "Votre LIMITE de transaction mernsuelle a ete atteinte, merci de creer un compte pour beneficier des paiements sans limite. #{App::PayMeQuick::App.app[:signature]}"
                      return false, {
                          title: "Echec transaction",
                          message: "Ce marchant ne peut plus effectuer une transaction, il a atteint son quota journalier de transaction"
                      }
                    else
                      # Commencons la transaction
                      # Authenticating customer with password
                      if @customer.valid_password?(password)

                        #debit customer account with amount + commission
                        if @customer.account.update(amount: Parametre::Parametre::soldeTest(@customer.account.amount, amount))

                          # Save this first customer transaction to history
                          customer_logs = History.new(
                              customer_id: @customer.id,
                              amount: Parametre::Parametre::agis_percentage(@amount),
                              context: "Mobile".upcase,
                              ip: @ip,
                              flag: 'paiement'.upcase,
                              code: code
                          )

                          if customer_logs.save
                            # Yes, customer transaction has been saved
                            # Credit merchant account with amount of transaction

                            Rails::logger.info "Debit du compte client #{customer} effectué avec succes!"

                            merchant_amount = @merchant.account.amount += amount.to_f
                            if @merchant.account.update(amount: merchant_amount)

                              # save this second merchant transaction to history
                              merchant_logs = History.new(
                                customer_id: @merchant.id,
                                amount: @amount,
                                code: code,
                                flag: "encaissement".upcase,
                                context: "Mobile".upcase,
                                ip: @ip
                              )

                              if merchant_logs.save
                                # creation des commissions de transaction
                                commission = Parametre::Parametre::commission(code, amount, Parametre::Parametre::agis_percentage(amount).to_f, (Parametre::Parametre::agis_percentage(amount).to_f - amount))

                                # verifions si tout cela a été entegistré
                                if commission
                                  # Send SMS to merchant
                                  Sms.sender(@merchant.phone, "Paiement recu. Montant: #{amount}, Payeur: #{@customer.complete_name}, ID Transaction: #{code}, Date: #{Time.now.strftime("%d-%m-%Y, %Hh:%M")}")

                                  # respond to customer
                                  return true, {
                                    amount: amount,
                                    device: "XAF",
                                    frais: (Parametre::Parametre::agis_percentage(amount).to_f - amount).round(2),
                                    total: (Parametre::Parametre::agis_percentage(amount).to_f).round(2),
                                    receiver: @marchand.complete_name,
                                    sender: customer.complete_name,
                                    date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                                    status: I18n.t("done", locale: locale)
                                  }
                                else
                                  # Annuler toute la transaction
                                  raise ActiveRecord::Rollback "Des erreur sont survenues durant l'enregistrement de la commission, annulation de la transaction"
                                end
                              else
                                # Annulation de la transaction
                                raise ActiveRecord::Rollback "Des erreur sont survenues durant la sauvegarde de l'historique. Annulation ..."
                              end
                            else
                              raise ActiveRecord::Rollback "Des erreur sont survenues durant la mise a jour du compte marchand. Annulation ..."
                            end
                          else
                            raise ActiveRecord::Rollback "Des erreur sont survenues durant la journalisation du compte client. Annulation ..."
                          end
                        else
                          #Raise ActiveRecord::RollBack transaction and history
                          Rails::logger.info "Impossible de credite le compte du customer ... Annulation"
                          raise ActiveRecord::Rollback "Annulation de la transaction, des erreurs sont survenue durant la mise a jour du compte client..."
                        end
                      end
                    end
                  end
                end
              end
            else
              # merchant is not demo user account
              Rails::logger.info "Merchant is not demo user, He have a normal account
"
              # Commencons la transaction pour un marchand normal
              # Authenticating customer with password
              if @customer.valid_password?(password)

                #debit customer account with amount + commission
                if @customer.account.update(amount: Parametre::Parametre::soldeTest(@customer.account.amount, amount))

                  # Save this first customer transaction to history
                  customer_logs = History.new(
                      customer_id: @customer.id,
                      amount: Parametre::Parametre::agis_percentage(@amount),
                      context: "Mobile".upcase,
                      ip: ip,
                      flag: 'paiement'.upcase,
                      code: code
                  )

                  if customer_logs.save
                    # Yes, customer transaction has been saved
                    # Credit merchant account with amount of transaction
                    merchant_amount = @merchant.account.amount += amount.to_f
                    if @merchant.account.update(amount: merchant_amount)

                      # save this second merchant transaction to history
                      merchant_logs = History.new(
                          customer_id: @merchant.id,
                          amount: @amount,
                          code: code,
                          flag: "encaissement".upcase,
                          context: "Mobile".upcase,
                          ip: ip
                      )

                      if merchant_logs.save
                        # creation des commissions de transaction
                        commission = Parametre::Parametre::commission(code, amount, Parametre::Parametre::agis_percentage(amount).to_f, (Parametre::Parametre::agis_percentage(amount).to_f - amount))

                        # verifions si tout cela a été entegistré
                        if commission
                          # Send SMS to merchant
                          Sms.sender(@merchant.phone, "Paiement recu. Montant: #{amount}, Payeur: #{@customer.complete_name}, ID Transaction: #{code}, Date: #{Time.now.strftime("%d-%m-%Y, %Hh:%M")}")

                          # respond to customer
                          return true, {
                              amount: amount,
                              device: "XAF",
                              frais: (Parametre::Parametre::agis_percentage(amount).to_f - amount).round(2),
                              total: (Parametre::Parametre::agis_percentage(amount).to_f).round(2),
                              receiver: @marchand.complete_name,
                              sender: customer.complete_name,
                              date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                              status: I18n.t("done", locale: locale)
                          }
                        else
                          # Annuler toute la transaction
                          raise ActiveRecord::Rollback "Des erreur sont survenues durant l'enregistrement de la commission, annulation de la transaction"
                        end
                      else
                        # Annulation de la transaction
                        raise ActiveRecord::Rollback "Des erreur sont survenues durant la sauvegarde de l'historique. Annulation ..."
                      end
                    else
                      raise ActiveRecord::Rollback "Des erreur sont survenues durant la mise a jour du compte marchand. Annulation ..."
                    end
                  else
                    raise ActiveRecord::Rollback "Des erreur sont survenues durant la journalisation du compte client. Annulation ..."
                  end
                else
                  #Raise ActiveRecord::RollBack transaction and history
                  Rails::logger.info "Impossible de credite le compte du customer ... Annulation"
                  raise ActiveRecord::Rollback "Annulation de la transaction, des erreurs sont survenue durant la mise a jour du compte client..."
                end
              end
            end
          end
        end
      end
    end
end