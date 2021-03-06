#SPRINTPAY MODULE PAYMENT MOBILE
# TODO nothing for now on this module

module SprintPay

  module Check
    class CheckPhone
      def initialize(*args)
        $phone = args[0][:phone]
        $amount = args[0][:amount]
      end

      # TODO permet de verifier le numero de telephone
      def self.verifyPhone
        #tableau d'operateur mobile et des numero permettant de les indentifier
        @ORANGE = %w(55 91 90 98 96 95)
        @MTN = %w(51 71 70 50 51 54)

        #on recupere le numero et on le converti en string
        phone = $phone.to_s

        if phone.length == 9

          #on recupere les 3 premiers caracteres
          char = phone[1..2]
          puts char

          #TODO verifier la compatibilité avec les operateur ORANGE ET MTN

          if @ORANGE.include? char #on recherche la compatibilité avec orange

            return 'orange'

          elsif @MTN.include? char #on recherche la compatibilité chez MTN

            return 'mtn'

          else

            return 'inconnu'

          end

        else

          return 'Impossible de continuer, format de numéro erroné'

        end
      end

      # TODO permet de verifier le montant
      def self.verify_amount
        if $amount.is_a?(String)
          return false
        elsif $amount.is_a?(Integer)
          return true
        end
      end
    end
  end

  # TODO module pour le paiement
  module Pay

    class Payment

      include HTTParty

      HEADERS = {
        "Authorization": "SP:2c110723-f334-4638-a610-1d575eefd60f:MjBmNjBjNzg5YmE3MWYwYTAxM2Y4Nzg3ODViYjRlOTRkZjAwYTYxMg==",
        "DateTime": "2018-12-05T18:55:25Z",
        "Content-Type": "application/json"
      }

      def initialize(phone, amount)
        $phone = phone
        $amount = amount
      end

      #inclussion test
      def self.includeKey
        request = HTTParty.get('http://localhost/printsdk')
        return request
      end

      #ENVOI
      # @param [Object] body
      # @param [Object] url
      def self.send(body, url)
        # https://test-api.sprint-pay.com/sprintpayapi/payment/mobilemoney/request/v3 || v2
        # https://test-api.sprint-pay.com/sprintpayapi/payment/orangemoney/request/v3 || V2

        begin

          q = HTTParty.post(url, headers: HEADERS, body: body, timeout: 30)
          return q.as_json

        rescue StandardError => e #, Timeout::Error, NetworkError::Timeout, NetworkError::Error

          return "Une erreur est survenue. Impossible de continuer : #{e}"

        end
      end

      #ENVOI OM VERS CLIENTS ORANGE MONEY
      def self.orange
        base_url = "https://test-api.sprint-pay.com/sprintpayapi/payment/orangemoney/request/v3"
        body_data = {
          "phone": $phone,        #utiliser la variable globale disponible a cet effet
          "amount": $amount,       #utiliser le montant globale disponible a cet effet
          "notify_url": "https://google.cm",
          "return_url": "https://google.cm",
          "cancel_url": "https://google.cm",
        }.to_json

        send(body_data, base_url)
      end

      # Permet de paiement vers orange money :: REFACTORING
      def self.om
        
      end

      #ENVOI D UN MOMO VERS LES CLIENTS MTN MOBILE MONEY
      def self.mtn
        base_url = "https://test-api.sprint-pay.com/sprintpayapi/payment/mobilemoney/request/v2"
        #base_url = "https://test-api.sprint-pay.com/sprintpayapi/payment/orangemoney/request/v3"
        body_data = {
          "phone": $phone,        #utiliser la variable globale disponible a cet effet
          "amount": $amount       #utiliser le montant globale disponible a cet effet
        }.to_json

        send(body_data, base_url)

      end

      #viartual SprintLocalAPI
      def self.sp(token, phone, amount, network_name)
        @token = token
        @phone = phone
        @montant = amount
        @network_name = network_name
        @hash = "PR_PROVIDER_#{SecureRandom.hex(13).upcase}"

        #set limit
        puts "Verification de la limite de recharge"
        if @montant.to_f > 500000.to_f
          return false, {
            title: "Erreur montant",
            message: "Impossible de crediter un montant superieur à 500 000 F CFA"
          }
        else
          #sleep for 5 seconds
          puts "sleep for 5 seconds ..."
          sleep 5

          # searching customer
          puts "Searching customer informations ..."
          customer = Customer.find_by_authentication_token(@token)
          if customer.blank?
            return false, "Utilisateur inconnu"
          else
            # starting credit customer account
            new_account = customer.account.amount + @montant.to_f

            #update customer account
            puts "updating customer amount information ..."
            account = customer.account.update(amount: new_account)
            if account
              #update history
              history = History.new(
                customer_id: customer.id,
                amount: @montant.to_f,
                flag: "RECHARGE",
                context: "RECHARGE #{@network_name.upcase}",
                code: @hash
              )

              if history.save
                #new entry created
                Sms.nexah(@phone, "Recharge de votre compte via #{@network_name.upcase} d'un montant de #{@montant} F CFA. Votre solde est maintenant de #{customer.account.amount} F CFA.")
                return true, {
                  title: "Recharge effectuée",
                  message: "Votre compte #{@phone} correspondant à #{@network_name.upcase} a été debité d'un montant de #{@montant} F CFA. Le sole de votre compte PMQ est de #{customer.account.amount} F CFA"
                }
              else
                puts "Impossible de rsauvegarder les informations"
                return false, {
                  title: "Erreur survenue",
                  message: "Impossible de terminer la transaction de recharge, annulation de tous les process"
                }
              end
            else
              return false, {
                title: "Impossible de recharger",
                message: "Impossible d'effectuer la reccharge, le solde de votre compte est insiffisant."
              }
            end
          end
        end
      end

    end

  end


  # New SprintPay payment API
  module V2
    class SP
      def keys
        date  = DateTime.parse(Time.now.to_s).iso8601
      end
    end
  end
end