#Gestion des utilisateurs externe a la plateforme
module External
  #limit de request de paiement par jour et par mois
  $limit_payment_day = 10
  $limit_payment_mounth = 100

  #limit de montant perceptible par jour et par mois
  $limit_payment_amount_day = 10000
  $limit_payment_amount_mount = 50000

  #debut et fin du mois
  $start_date_demo_user = Date.today
  $end_date_demo_user = 30.days.from_now


  #permet de gerer l'utilisateur demo, n'ayant pas de compte
  class DemoUsers

    #recherche si un demo_user existe en se basant sur son numero
    def self.is_exist?(phone)
      @phone = phone

      demo_user = DemoUser.find_by_phone(phone)
      if demo_user.blank?
        Rails::logger.info "Utilisateur #{@phone} inexistant dans la DemoUser"
        return false, "Not found"
      else
        Rails::logger.info "Utilisateur #{@phone} trouvé et existant  depuis le #{demo_user.created_at}"
        return true, demo_user.as_json(only: [:phone, :id, :key, :date_debut, :date_fin, :status, "#{DemoUserAccount.find_by_demo_user_id(demo_user.id).amount}"])
      end
    end

    #permt de creer un nouvelle enregistrement sur la base du telephone
    # @param [String] phone
    def self.new_demo_user(phone, amount, payeur)
      @phone  = phone
      @amount = amount
      @payeur = payeur

      #search phone inside customer DB table
      customer = Customer.find_by_phone(@phone)
      if customer.blank?
        #effectivement ce numero ne figure pas dans le client reel de paymequick
        #on recherche dans DemoUser
        Rails::logger.info "Utilisateur #{@phone} inexistant dans la table des Customer"
        customerDemo = DemoUser.find_by_phone(@phone)
        if customerDemo.blank?
          Rails::logger.info "Utilisateur #{@phone} inexistant dans la table des demoUser"
          #on fait un nouvel enregistrement pour ce cas
          demo_user = DemoUser.new(
              phone: @phone,
              date_debut: $start_date_demo_user,
              date_fin: $end_date_demo_user,
              request_day: 0,
              request_mount: 0,
              status: "activate",
              # key: AES.encrypt(@phone.to_s, Client.key)
          )
          if demo_user.save

            #normalement on devrait creer aussi le compte demo_user_account, create demo account
            new_account = new_demo_user_account(demo_user.id)
            if new_account
              #creation effectif du compte financier de demoUser
              return true, "New demo account created for #{@phone}"
            else
              return false, "Une erreur est survenue : #{new_account.errors.full_messages}"
            end
            #return true, demo_user.as_json(only: [:id, :phone, "#{DemoUserAccount.find_by_demo_user_id(demo_user.id).amount}"])
          else
            return false, "Impossible de creer demo user : #{demo_user.errors.full_messages.to_json}"
          end
        else

          #We found an existing demoUser Account, so we can credit this account

          Rails::logger.info "#{@phone} has been found on DemoUser Databases"

          request = credit_demo_user(@phone, @amount, @payeur)

          return request[0], request[1], "Demo customer existe dans la bd demoUser", customerDemo.as_json(only: [:phone])

        end

      else

        return false, "c'est un normal customer", customer.as_json(only: [:name, :second_name, :phone, :authentication_token])

      end

    end


    #create demo user account
    # @param [Integer] demo_user_id
    def self.new_demo_user_account(demo_id)
      @demo_user_id = demo_id

      #start create account
      new_account = DemoUserAccount.new(demo_user_id: @demo_user_id, amount: 0.0)
      if new_account.save
        return true, "created"
      else
        return false, "Errors are : #{new_account.errors.full_messages}"
      end

    end


    #crediter le compte de demo user
    # @param [String] phone
    # @param [Float] amount
    def self.credit_demo_user(marchant_phone, amount, payeur_phone)

      @phone = marchant_phone
      @amount = amount
      @payeur = payeur_phone

      #check if demoCustomer exist
      data = is_exist?(@phone)

      #check if demo_user exist
      if data[0]
        #get current account

        demo_current_account = DemoUser.find_by_phone(@phone).demo_user_account
        if demo_current_account.blank?

          return false, "conmpte virtuel inexistant."

        else

          #starting request payeur account authorization status
          authorization = Customer.find_by_phone(@payeur).account
          if authorization.amount.to_f >= @amount.to_f

            @montant.to_f += demo_current_account.amount.to_f

            #credit virtal account
            if demo_current_account.update(demo_user_id: data[1]['id'], amount: @montant)

              Rails::logger.info "Paiement effectué d'un montant de #{@amount}"

              Sms.sender(@phone, "Payment recu d'un montant de #{@amount} F CFA, nouveau solde : F CFA #{demo_current_account.amount}. PayMeQuick")

              return true, demo_current_account.as_json(only: :amount), "credité"
            else
              return false, "Une erreur est survenue : #{demo_current_account.errors.full_messages}"
            end

          else

            Rails::logger.info "Solde insuffisant sur le compte #{@payeur}"

            Sms.sender(@phone, "Votre solde est insuffisant pour effectuer cette transaction.")

            return false, "Impossible de terminer la transaction, Solde insuffisant"

          end

        end

      end

    end


    #Permet de verifier le payeur du voucher
    def self.checkSender(sender)
      @sender = sender #.to_i if sender.is_a?(String)

      #check sender
      s = Customer.find_by_phone(@sender)
      if s.blank?
        #sender not found
        return false, "Unknow sender"
      else
        return true, s.as_json(only: [:name, :second_name])
      end
    end


    #attribut un montant a un numero n'appartenant pas à la plateforme
    def self.voucher(merchant, amount, sender)
      @phone = merchant #for customer who don't have paymequick account
      @amount = amount #amount of transaction
      @sender = sender #person who buy service

      #check customer
      s = checkSender(@sender)
      if s[0]
        customer = Customer.find_by_phone(@phone)
        if customer.blank?
          #user not find, and that is good we have to create new user to make virtual payment

          #find customer to viartual outside customer model
          virtual_demo = DemoUser.find_by_phone(@phone)
          if virtual_demo.blank?
            #it's the first time that we see the user demo request, save as new record
            query = new_demo_user(@phone)
            if query[0]
              #update new demo account
              update_demo_account = credit_demo_user(@phone, @amount)
            end
          end


          Sms.new(@phone, "Mr/Mme, Vous venez de recevoir un paiement de #{@amount} #{$devise} provenant de #{s[1]["name"]} #{s[1]["second_name"]} a #{Time.now}. Code retrait PEXT#{rand(11 ** 11)}. Profiter et creer un compte #{Client.appName} pour beneficier de tous les avantages sur https://me.paimequick.com/user/signup?phone=#{@phone}. Si vous etes Android, telecharger #{Client.appName} sur https://play.google.com/store/apps/details?id=com.agis.payQuick")
          Sms.send
          return true, "Utilisateur externe #{@phone} vient d'etre payé d'un montant de #{@amount} #{$devise}. #{Client.appName}"
        else
          #customer found inside plateform, notify
          Rails::logger::info "Vous etes deja sur la plateforme, merci de scanner le QR Code"
          #demander à l'utilisateur qui est deja sur la plateforme de scanner le qrcode
          #Client.credit_account(@phone, @amount)
          return false, "Merci de scanner le QRCode de cet utilisateur pour effectuer votre transaction"
        end

      else

        Rails::logger::info "Payeur inconnu"
        return false, "Utilisateur inconnu sur la plateforme #{Client.appName}"

      end


    end

  end

end