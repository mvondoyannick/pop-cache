module Pay

  class Pay

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

    #pour permettre l'envoi via OM
    def self.send(body)
        #https://test-api.sprint-pay.com/sprintpayapi/payment/mobilemoney/request/v3
        q = HTTParty.post('https://test-api.sprint-pay.com/sprintpayapi/payment/orangemoney/request/v3', headers: HEADERS, body: body)
        return q.as_json
    end

    #pour permettre l'envoi via MTN MOMO
    def self.send_momo(body)
      #https://test-api.sprint-pay.com/sprintpayapi/payment/mobilemoney/request/v3
      q = HTTParty.post('https://test-api.sprint-pay.com/sprintpayapi/payment/mobilemoney/request/v3', headers: HEADERS, body: body)
      return q.as_json
  end

    def self.pay_orange
      body_data = {
          "phone": $phone, #utiliser la variable globale disponible a cet effet
          "amount": $amount       #utiliser le montant globale disponible a cet effet
      }.to_json

      send(body_data)
    end

    def self.pay_mtn
      body_data = {
          "phone": $phone, #utiliser la variable globale disponible a cet effet
          "amount": $amount       #utiliser le montant globale disponible a cet effet
      }.to_json

      send_momo(body_data)
    end

    #permet d'effectuer la verification du telephone
    def self.checkPhone
    end

    #permet de verifier le formar du paiement
    def self.checkAmount
        if $amount.is_a?(String)
            return false
          elsif $amount.is_a?(Integer)
            return true
        end
    end

    #paiement via OM
    def self.pay

    end

  end

  class Payment

    def self.pay(argv, message, locale)
      @from = argv[:from]
      @to = argv[:to]
      @amount = argv[:amount].to_f
      @client_password = argv[:pwd]
      @ip = argv[:ip]
      @lat = argv[:lat]
      @lon = argv[:lon]

      message = message
      locale = locale

      marchand = Customer.find(@to) #personne qui recoit
      marchand_account = marchand.account #Account.where(customer_id: marchand.id).first #le montant de la personne qui recoit
      client = Customer.find(@from) #la personne qui envoi
      client_account = client.account #Account.where(customer_id: client.id).first # le montant de la personne qui envoi

      if @from == @to
        #Send local Pushnotifications here
        #OneSignal::OneSignalSend.notPayToMe(@playerId, "#{client.name} #{client.second_name}") #sendNotification(@playerId, Parametre::Parametre.agis_percentage(@amount),"#{marchand.name} #{marchand.second_name}", "#{client.name} #{client.second_name}")
        # end sending local notifications
        Rails::logger::info "Numéro indentique, transaction annuler!"
        return false, {
            title: I18n.t("merchantNotValid", locale: locale),
            message: "#{prettyCallSexe(client.sexe)} #{client.complete_name} vous ne pouvez pas vous payer à vous même. Merci de verifier votre destinataire et réessayer."
        }
      else
        if client.valid_password?(@client_password)
          Rails::logger::info "Client identifié avec succes!"

          #contrainte si le montant depasse 150 000 F CFA XAF
          if @amount > $limit_amount
            Rails::logger::info "Limite de transaction de 150 000 F depassée"
            return false, {
                title: I18n.t("transactionLimit", locale: locale),
                message: "#{prettyCallSexe(client.sexe)} #{client.complete_name} il semblerait que votre transaction dépasse la limité autorisée de #{$limit_amount} #{$devise}. Merci de revoir le montant de votre transaction."
            }
          else
            if client_account.amount.to_f >= Parametre::Parametre::agis_percentage(@amount)
              Rails::logger::info "Le montant est suffisant dans le compte du client, demarrage de la transaction ..."
              @hash = "PP_#{SecureRandom.hex(13).upcase}"
              # client_account.amount = Parametre::Parametre::soldeTest(client_account.amount, amount) #client_account.amount.to_f - Parametre::Parametre::agis_percentage(@amount).to_f #@amount
              if client_account.update(amount: Parametre::Parametre::soldeTest(client_account.amount, amount))
                # if client_account.save
                Rails::logger::info "Solde dans le compte du client #{client.phone} : #{client_account.amount.to_f}"
                marchand_account.amount += @amount

                #on historise la transaction du marche
                #saveHistory(@to, @hash,"ENCAISSEMENT","none",@amount,nil ,nil ,nil )
                marchant_log = History.new(
                    customer_id: marchand.id,
                    amount: @amount,
                    code: @hash,
                    flag: "encaissement".upcase,
                    context: "Mobile".upcase,
                    ip: @ip
                )

                #on enregistre
                marchant_log.save

                if marchand_account.save
                  #envoi d'une notification OneSignal
                  Sms.sender(marchand.phone, "Paiement recu. Montant :  #{@amount.round(2)} F CFA XAF, \t Payeur : #{prettyCallSexe(client.sexe)} #{client.complete_name}. Votre nouveau solde:  #{marchand_account.amount} F CFA XAF. Transaction ID : #{@hash}. Date : #{Time.now}. #{App::PayMeQuick::App::app[:signature]}")

                  Rails::logger::info "Paiement effectué de #{@amount} entre #{@from} et #{@to}."

                  #on enregistre encore l'historique
                  client_log = History.new(
                      customer_id: client.id,
                      amount: Parametre::Parametre::agis_percentage(@amount),
                      context: "Mobile".upcase,
                      ip: @ip,
                      flag: 'paiement'.upcase,
                      code: @hash
                  )

                  if client_log.save

                    #fin de journalisation
                    Rails::logger::info "Historique de transaction enregistrée avec succes"

                    #enregistrement des commissions
                    commission = Parametre::Parametre::commission(@hash, @amount, Parametre::Parametre::agis_percentage(@amount).to_f, (Parametre::Parametre::agis_percentage(@amount).to_f - @amount))
                    if commission
                      #fin d'enregistrement de la commission
                      a = {
                          amount: @amount,
                          device: 'XAF',
                          frais: Parametre::Parametre::agis_percentage(@amount).to_f - @amount,
                          total: Parametre::Parametre::agis_percentage(@amount).to_f,
                          receiver: marchand.complete_name,
                          sender: client.complete_name,
                          date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                          status: "DONE"
                      }
                      Rails::logger.info "Transaction response => #{a}"

                      #return true, "Votre Paiement de #{@amount} F CFA vient de s'effectuer avec succes. \t Frais de commission : #{(Parametre::Parametre::agis_percentage(@amount).to_f - @amount).round(2)} F CFA. \t Total prelevé de votre compte : #{Parametre::Parametre::agis_percentage(@amount).to_f.round(2)} F CFA. \t Nouveau solde : #{client_account.amount.round(2)} #{$devise}."
                      return true, {
                          amount: @amount,
                          device: "XAF",
                          frais: (Parametre::Parametre::agis_percentage(@amount).to_f - @amount).round(2),
                          total: (Parametre::Parametre::agis_percentage(@amount).to_f).round(2),
                          receiver: marchand.complete_name,
                          sender: client.complete_name,
                          date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                          status: "DONE"
                      }
                    else
                      Rails::logger.info "Impossible d'entregistrer les commissions de cette transaction"
                    end

                  else

                    Rails::logger.info "Impossible d'enregistrer les informations de transation du paiement #{@hash}"

                  end
                else
                  # raise ActiveRecord::Rollback
                  Rails::logger::info "Impossible de crediter le marchand #{marchand.authentication_token} d'un montant de #{@amount} F CFA"
                  Sms.sender(marchand.phone, "Impossible de crediter votre compte de #{amount}. Transaction annulee. #{$signature}")
                  return false
                end
              else
                Rails::logger::info "Impossible de mettre à jour les informations du client sur la transaction N° #{@hash}, d'un montant de #{@amount} F CFA"
                Sms.sender(client.phone, "Impossible d\n'acceder a votre compte. Transaction annulee. #{$signature}")
                return false
              end
            else
              Rails::logger::info "Le solde du compte client #{client.phone} est insuffisant pour effectuer la transaction de paiement d'un montant de #{@amount}. Paiment impossible"
              return false, {
                  title: "SOLDE INSUFFISANT",
                  message: "Le solde de votre compte est insuffisant pour effectuer cette transaction! Merci de recharger votre compte!"
              }
            end
          end
        else
          Rails::logger::info "Invalid user password authentication"
          return false, {
              title: "ECHEC IDENTIFICATION",
              message: "Le mot de passe utilisé est invalide, merci de réessayer!"
          }
        end
      end
    end
  end

end