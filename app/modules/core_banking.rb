# manage tous les aspects liés avec une banque
# @name CoreBanking module
module CoreBanking
  require 'prawn'
  require 'open-uri'
  require 'action_controller'
  require 'action_view'

  class Document < Prawn::Document

    def self.generate
      pdf = Prawn::Document.new
      y_position = pdf.cursor
      pdf.image "#{Rails.root}/fc.png", scale: 0.45
      #pdf.text "Hello to prawn"
      pdf.move_down 50
      pdf.image "#{Rails.root}/test.svg.png", scale: 0.35, position: 427, vposition: 15
      pdf.move_down 20
      pdf.encrypt_document(user_password: "lorem")
      a = pdf.render_file "lorem.pdf"
      return true, Rails.root.join + "lorem.pdf"
    end

  end

  class Bank

    # Permet de crediter un compte bancaire à partir de son compte PMQ
    def creditBankAccount

    end

    # Permet de debiter un compte bancaire et de crediter son compte PMQ
    def debitBankAccount

    end

    # Ajouter un compte bancaire rattacher à son compte PMQ
    def AddBankAccount

    end

    # Supprimer un compte bancaire lié à son compte PMQ
    def deleteBankAccount

    end

    # Suspendre un compte bancaire rattaché à son compte PMQ
    # @param [Object] argv
    # @param [String] action
    # @param [String] langue
    def suspendBankAccount(argv, action, langue)

      @argv = argv
      @action = action
      @langue = langue

    end

  end

  class FlashCash

    def initialize(argv, action, langue)

    end

    # Check if CF exist or have an account
    # @param [String] authentication_token
    # @param [String] intent
    # @param [String] lang
    def self.FcAccountHaveAmount?(authentication_token, intent = "Check FC Account", lang = "Fr")

      @authentication_token = authentication_token
      @intent = intent
      @lang = lang

      if Customer.exists?(authentication_token: @authentication_token)
        @customer = Customer.find_by(authentication_token: @authentication_token)

        if @customer.fc_account.nil?
          return false, "Vous ne disposez pas encore de compte Flash Cash"
        else
          return true, @customer.fc_account.amount
        end


      else
        return false, "Utilisateur ou compte inconnu"
      end
    end

    # Creer un FlashCash
    def self.createFC(argv, intend, lang = nil)
      @sender = argv[:authentication_token]
      @receiver = argv[:receiver].to_i
      @amount = argv[:amount].to_f
      @devise = device
      @intent = intent

      @customer = Customer.find_by(authentication_token: @sender, two_fa: "authenticate")
      if @customer.account.amount >= @amount

      else
        return false, "Solde du compte insuffisant pour creer ce Flash Cash"
      end
    end

    # demande autorisation de creer une Flash Cash
    # @param [Object] argv
    # @param [String] device
    # @param [String] intent
    def self.requestFC(argv, device = "CFA", intent = "Authorisation Flash Cash")
      @sender = argv[:authentication_token]
      @receiver = argv[:receiver].to_i
      @amount = argv[:amount].to_f
      @devise = device
      @intent = intent

      if Customer.exists?(authentication_token: @sender)
        # verify if customer have money in his account
        @customer = Customer.find_by(authentication_token: @sender)
        if @customer.account.amount >= @amount

          # Starting to send request ton AFB API for generating FlashCash
          return true, {
            receiver: @receiver,
            amount: @amount,
            devise: @devise,
            emetteur: @customer.complete_name,
            intent: @intent
          }

        else
          render false, "Solde insuffisant pour generer une authorisation de Flash Cash"
        end
      else
        return false, "Utilisateur ou compte inconnu"
      end

    end


    # debit PAYMEQUICK account andr credit Flash Cash account
    # @param [Object] argv
    # @param [String] intent
    # @param [String] lang
    def self.creditFcAccount(argv, intent = "Credit FC Account", lang = nil)
      @authentication_token = argv[:authentication_token]
      @amount = argv[:amount].to_f
      @intent = intent
      @lang = lang

      if Customer.exists?(authentication_token: @authentication_token)
        @customer = Customer.find_by(authentication_token: @authentication_token, two_fa: 'authenticate')

        if @customer.account.amount >= @amount
          # we can trigger activity
          @debit = @customer.account.amount - @amount

          #update customer account with new amount
          if @customer.account.update(amount: @debit.to_f)

            # check if this customer has an Flash Cash account
            if @customer.fc_account.nil?
              # create fc_account
              # credit FC account
              @new_account = FcAccount.new(account_code: @customer.code, amount: @amount, customer_id: @customer.id)
              if @new_account.save
                #update history
                if CoreHistory::Journal.generate(customer: @customer.id, code: nil, flag: nil, context: "Debit account", amount: @amount)
                  # send customer notifications
                  Sms.nexah(@customer.phone, "Compte PAYMEQUICK débité de #{@amount} CFA. Solde #{@debit.round(2)} CFA, compte Flash Cash crédité de #{@amount} CFA, solde : #{@customer.fc_account.amount.round(2)} CFA")
                  sleep 2
                  return true, "Flach Cash account credited"
                else
                  return false, "Une erreur est survenue!"
                end

              else

                return false, "Impossible de crediter votre compte flash cash"

              end

            else
              # just update an account
              # credit FC account
              @current = @customer.fc_account.amount + @amount

              if @customer.fc_account.update(account_code: @customer.code, amount: @current, customer_id: @customer.id)

                #update history
                if CoreHistory::Journal.generate(customer: @customer.id, code: nil, flag: nil, context: "Debit account", amount: @amount)
                  # send customer notifications
                  Sms.nexah(@customer.phone, "Compte PAYMEQUICK débité de #{@amount} CFA. Solde #{@debit} CFA, compte Flash Cash crédité de #{@amount.round(2)} CFA, solde : #{@current.round(2)} CFA")
                  return true, "Flach Cash account credited"
                else
                  return false, "Une erreur est survenue!"
                end

              else

                return false, "Impossible de crediter votre compte flash cash"

              end
            end

          else
            return false, "Impossible de debiter votre compte."
          end
        else
          return false, "Solde du compte insuffisant"
        end

      else

        return false, "compte incorrect ou Utilisateur inconnu"

      end
    end


    # generate new coupon
    # @version 0.1
    # @param [Object] argv
    # @param [String] intent
    # @param [String] lang
    def self.generateFcCoupon(argv, intent = "Generate coupon", lang = nil)
      @sender = argv[:authentication_token]
      @password = argv[:password]
      @amount = argv[:amount]
      @receiver = argv[:receiver].to_i
      @lat = argv[:lat]
      @lon = argv[:lon]
      @lang = lang
      @intent = intent

      if Customer.exists?(authentication_token: @sender)
        @customer = Customer.find_by(authentication_token: @sender)

        # check if sender & receiver are differents
        if @customer.phone.to_i == @receiver
          return false, "Impossible de se faire un Flash Cash "
        else
          if @customer&.valid_password?(@password)

            #check if customer have amount in his fc account
            if !@customer.fc_account.nil? && @customer.fc_account.amount >= @amount
              # create Flash Cash coupon
              @coupon_code = DateTime.now.to_i
              @coupon = FcCoupon.new(
                  amount: @amount,
                  coupon_code: @coupon_code,
                  receiver_phone: @receiver,
                  receiver_name: nil,
                  auth_coupon_code: nil,
                  fc_account_id: @customer.fc_account.id,
                  coupon_paid: false,
                  coupon_date_paid: nil,
                  agence_id: nil,
                  lat: @lat,
                  lon: @lon,
                  coupon_confirmation_code: nil,
                  customer_id: @customer.id
              )

              if @coupon.save
                # debit customer Flash cash account
                @fc_account_amount = @customer.fc_account.amount - @amount

                #update fc_account customer
                if @customer.fc_account.update(amount: @fc_account_amount)
                  #respond to customer"
                  Sms.nexah(@receiver, "#{Client.prettyCallSexe(@customer.sexe)} #{@customer.complete_name.upcase} vous a envoyé un Flash Cash d'une valeur de #{@amount.round(2)} F CFA. Le code de la transaction est : #{@coupon.coupon_code} bien vouloir le conserver précieusement. Merci de vous rendre dans une agence Afriland First Bank ou dans un GAB/DAB Afrilanf First Bank pour rentrer en possession de ce montant.")
                  sleep 2
                  return true, "Nouveau coupon enregistré"
                else
                  return false, "Impossible de mettre à jour votre compte Flash Cash"
                end
              else
                return false, "Impossible d'enregistrer un coupon : #{@coupon.errors.details}"
              end
            else
              return false, "Solde insuffisant dans votre Flash Cash"
            end

          else
            return false, "Utilisateur ou mot de passe incorrect"
          end
        end
      else
        return false, "Utilisateur ou compte inconnu"
      end
    end

    def self.cancelFcCoupon(argv, intent, lang = nil)

    end

    def self.blockFcCoupon(argv, intent, lang = nil)

    end

    # Annuler l'emission d'un flashCash precedement generé
    def self.cancelFlashCash(argv)

    end

    # Notifier que le flashCash precedement generé à été validé
    def self.notifyFlashCash(argv)

    end

  end

  class Journal

    # historique journalier, retourn un document PDF à une adresse
    def dayly

    end

    def self.send_csv
      csv = History.generate_csv
      email = "mvondoyannick@gmail.com"
      JobMailer.send_csv(email, csv).deliver
    end

    # historique hebdomadaire, retourn un document PDF des activités hebdomadaires de transaction
    def weekly

    end

  end

  class Rapprochement

  end

end