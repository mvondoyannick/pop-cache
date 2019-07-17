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

    def self.Payment(argv)
      @customer_token = argv[:token]
      @customer_password = argv[:password]
      @merchant_phone = argv[:phone]
      @amount = argv[:amount]
      @hash = rand(11**11)
      @ip = argv[:ip]

      # get data from IP transaction
      adress = DistanceMatrix::DistanceMatrix::pays(@ip)

      Rails::logger.info "Starting phone payement ..."

      Rails::logger.info "Verifiying Account customer amount ..."

      # Recherche le customer pour authentification
      customer = Customer.find_by_authentication_token(@customer_token)
      if customer && customer.valid_password?(@customer_password)

        Rails::logger.info "Customer/Payer found and all his data are ok ..."

        if customer.account.amount.to_f < @amount.to_f

          return false, "#{Client.prettyCallSexe(customer.sexe)} #{customer.complete_name} le solde de votre compte est insuffisant pour effectuer la transaction. Merci de le recharger et de réessayer."

        else

          # Verifier que le client ne se paye pas a lui même
          if customer.phone == @merchant_phone

            return false, "#{Client.prettyCallSexe(customer.sexe)} #{customer.complete_name} vous ne pouvez pas vous payer à vous même. Merci de changer le numéro du marchand et de réessayer."

          else

            # verifier qu'il s'agisse bien d'un numero du Cameroun...pour le moment
            if Parametre::PersonalData::numeroCameroun(@merchant_phone)

              # Ce numéro est un numéro camerounais, we can process
              #searching for merchant
              merchant = Customer.find_by_phone(@merchant_phone)
              if merchant.blank?
                Rails::logger.info "Merchant phone don't found inside the plateforme..."
                # on n'a pas trouver le marchand, on le cree directement et on credit son compte puis le le notifie par SMS
                new_merchant = Customer.new(
                  email: Faker::Internet.email,
                  password: Faker::Internet.password(8),
                  name: Faker::Name.first_name,
                  second_name: Faker::Name.last_name,
                  phone: @merchant_phone,
                  cni: Faker::Code.imei,
                  type_id: 2,
                  sexe: Faker::Gender.binary_type
                )

                #trying to save new demo customer
                if new_merchant.save
                  Rails::logger.info "Save new merchant informations DB."
                  #trying to create new_merchant account and store data amount
                  new_merchant_account = Account.new(
                    customer_id: new_merchant.id,
                    amount: @amount
                  )

                  # creating account
                  if new_merchant_account.save

                    client = History.new(
                      customer_id: customer.id,
                      amount: Parametre::Parametre::agis_percentage(@amount),
                      context: 'phone',
                      flag: 'paiement'.upcase,
                      code: "EXT_PAY_#{@hash}",
                      region: adress
                    )

                    # Historique du client
                    if client.save

                      # Historique du marchand virtuel pour le moment
                      marchand = History.new(
                        customer_id: customer.id,
                        amount: @amount,
                        context: 'phone',
                        flag: 'paiement'.upcase,
                        code: "EXT_PAY_#{@hash}",
                        region: adress
                      )

                      if marchand.save

                        Rails::logger.info "Save new merchant account information"
                        Sms.sender(@merchant_phone, "Bonjour, un Paiement de #{@amount} F CFA vient d etre effectue dans votre compte virtuel/numero de telephone #{@merchant_phone}. ID de la transaction EXT_PAY_#{@hash}. Rapprochez-vous d'une agence UBA ou creer un compte PayMeQuick.")
                        return true, "Paiement effectué d'un montant de #{Parametre::Parametre::agis_percentage(@amount)} à #{@merchant_phone}"

                      else

                        return false, "Impossible de mettre à jour l'historique du marchand virtuel : #{marchand.errors.full_messages}"

                      end
                    else

                      return false, "Impossible de mettre a jour l'historique du payeur/Client : #{client.errors.full_messages}"

                    end
                  end
                end

              else
                #merchant exist in DB, juste update his account
                Rails::logger.info "The merchant exist in the DB ..."
                if customer.account.update(amount: customer.account.amount.to_f - @amount.to_f)

                  m_account = Customer.find_by_phone(@merchant_phone).account

                  if m_account.update(amount: m_account.amount.to_f + @amount.to_f)
                    marchant = History.new(
                      customer_id: Customer.find_by_phone(@merchant_phone).id,
                      amount: @amount,
                      context: 'phone',
                      flag: 'encaissement'.upcase,
                      code: "EXT_PAY_#{@hash}",
                      region: adress
                    )

                    if marchant.save

                      client = History.new(
                        customer_id: customer.id,
                        amount: Parametre::Parametre::agis_percentage(@amount),
                        context: 'phone',
                        flag: 'paiement'.upcase,
                        code: "EXT_PAY_#{@hash}",
                        region: adress
                      )

                      if client.save
                        Sms.sender(@merchant_phone, "Bonjour, un Paiement d'un montant de #{@amount} F CFA vient d etre effectue dans votre compte #{@merchant_phone}. ID transaction EXT_PAY_#{@hash}. Le solde de votre compte est maintenant de #{m_account.amount} F CFA. Rapprochez-vous d'une agence UBA ou creer un compte PayMeQuick.")
                        return true, {
                          amount: @amount,
                          device: 'XAF',
                          frais: Parametre::Parametre::agis_percentage(@amount).to_f - @amount.to_f,
                          total: Parametre::Parametre::agis_percentage(@amount).to_f,
                          receiver: Customer.find_by_phone(@merchant_phone).complete_name,
                          sender: Customer.find_by_authentication_token(@customer_token).complete_name,
                          date: Time.now.strftime("%d-%m-%Y @ %H:%M"),
                          status: "DONE"
                        }#,"Paiement d'un montant de #{Parametre::Parametre::agis_percentage(@amount)} F CFA effectué au  #{@merchant_phone}."
                      else
                        return false, "Impossible de sauver l'historique : #{client.errors.full_messages}"
                      end

                    else

                      Rails::logger::info "Failed to save history on the plateforme"
                      return false, "Impossible de sauver l'historique : #{marchand.errors.full_messages}"

                    end

                  else

                    Rails::logger::info "Transaction failed during process"
                    return false, "Une erreur est survenue durant la transaction de paiement : #{m_account.errors.full_messages}"

                  end

                else

                  Rails::logger::info "Impossible de mettre a jour les informations du client"
                  return false, "Impossible de mettre à jour les informations du client"

                end

              end

            else

              return false, "Ce numéro #{@merchant_phone} ne semble pas etre un numéro appartenant au Cameroun. Merci de vérifier ce numéro et recommencer."

            end

          end

        end

      else
        Rails::logger::info "User password invalid"
        return false, "Mot de passe invalid"
      end

    end

  end

end