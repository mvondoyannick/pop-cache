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

      Rails::logger.info "Starting phone payement ..."

      # Recherche le customer pour authentification
      customer = Customer.find_by_authentication_token(@customer_token)
      if customer && customer.valid_password?(@customer_password)

        Rails::logger.info "Customer found and data are ok ..."

        #searching for merchant
        merchant = Customer.find_by_phone(@merchant_phone)
        if merchant.blank?
          Rails::logger.info "Merchant phone don't found ..."
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
                context: 'none',
                flag: 'paiement'.upcase,
                code: "EXT_PAY_#{@hash}"
              )

              # Historique du client
              if client.save

                # Historique du marchand virtuel pour le moment
                marchand = History.new(
                  customer_id: customer.id,
                  amount: @amount,
                  context: 'none',
                  flag: 'paiement'.upcase,
                  code: "EXT_PAY_#{@hash}"
                )

                if marchand.save

                  Rails::logger.info "Save new merchant account information"
                  Sms.sender(@merchant_phone, "Bonjour, un Paiement de #{@amount} F CFA vient d etre effectue dans votre compte virtuel/numero de telephone #{@merchant_phone}. ID de la transaction EXT_PAY_#{@hash}")
                  return true, "Paiement effectué d'un montant de #{Parametre::Parametre::agis_percentage(@amount)} à #{@merchant_phone}"

                else

                  return false, "Impossible de mettre a jour l'historique du marchand virtuel : #{marchand.errors.full_messages}"

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
                context: 'none',
                flag: 'encaissement'.upcase,
                code: "EXT_PAY_#{@hash}"
              )

              if marchant.save

                client = History.new(
                  customer_id: customer.id,
                  amount: Parametre::Parametre::agis_percentage(@amount),
                  context: 'none',
                  flag: 'paiement'.upcase,
                  code: "EXT_PAY_#{@hash}"
                )

                if client.save
                  Sms.sender(@merchant_phone, "Bonjour, un Paiement d'un montant de #{@amount} F CFA vient d etre effectue dans votre compte #{@merchant_phone}. ID transaction EXT_PAY_#{@hash}. Le solde de votre compte est maintenant de #{m_account.amount} F CFA")
                  return true, "Paiement d'un montant de #{Parametre::Parametre::agis_percentage(@amount)} effectué à #{@merchant_phone}."
                else
                  return false, "Impossible de sauver l'historique : #{client.errors.full_messages}"
                end

              else
                return false, "Impossible de sauver l'historique : #{marchand.errors.full_messages}"
              end

            else
              return false, "Une erreur est survenue durant la transaction de paiement : #{m_account.errors.full_messages}"
            end

          else

            return false, "Impossible de mettre à jour les informations du client"

          end

        end
      else
        return false, "Mot de passe invalid"
      end

    end

  end

end