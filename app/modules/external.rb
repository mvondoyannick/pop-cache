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


  # GESTION DES UTILISATEUR N AYANT PAS DE COMPTE SUR LA PLATEFORME
  class DemoUsers

    # CHECK IS USERS PHONE ARE DIFFEREBT
    # @params [Interger] phone
    def self.is_customer_different?(customer_phone, merchant_phone)
      @customer_phone = customer_phone.to_i
      @merchant_phone = merchant_phone.to_i

      puts "Customer phone : #{@customer_phone}"
      puts "Merchant phone : #{@merchant_phone}"


      if @customer_phone == @merchant_phone
        # the numbers are same
        return false
      else
        # two numbers are different
        return true
      end

    end

    # DEBIT LE COMPTE DU PAYEUR ET MET À JOUR SON SOLDE
    # @params [Integer] customer_id
    def self.debit_customer_account(customer_id, amount)
      @id = customer_id
      @amount = amount.to_f

      #get customer Datas
      customer = Customer.find(@id)

      if customer.account.amount >= @amount
        current_amount = customer.account.amount
        account_update = customer.account.update(amount: current_amount - Parametre::Parametre::agis_percentage(@amount))
        return true, account_update
      else
        return false, "solde insuffisant"
      end
    end

    def self.valid_customer_by_phone(phone, password)
      @phone = phone
      @password = password

      # begin ActiveRecord interrogation
      customer = Customer.find_by_phone(@phone)
      if customer && customer.valid_password?(@password)
        return customer.as_json(only: [:id, :name, :second_name, :code, :sexe, :email, :phone, :authentication_token])
      else
        return false
      end
    end

    def self.valid_customer_by_token(token, password)
      @token = token
      @password = password

      customer = Customer.find_by_authentication_token(@token)
      if customer && customer.valid_password?(@password)
        return customer.as_json(only: [:id, :name, :second_name, :code, :sexe, :email, :phone, :authentication_token])
      else
        return false
      end
    end

    # VERIFIE SUR SI LE PAYEUR A SUFFISAMENT DE ARGENT POUR LA TRANSACTION
    # @params [Interger] customer_id
    # @params [Float] amount
    def self.have_amount?(id, amount)
      @id = id
      @amount = amount.to_f

      customer_amount = Customer.find(@id).account.amount
      if customer_amount >= @amount
        return true
      else
        return false
      end
    end

    # PAYER UN NUMERO EXTERNE
    # @params [Object] argv
    def self.Pay(argv)
      @customer_token = argv[:token]
      @customer_password = argv[:password]
      @merchant_phone = argv[:phone].to_i #conversion en entier
      @amount = argv[:amount]
      @hash = rand(11**11)
      @ip = argv[:ip]
      @playerID = argv[:oneSignalID]

      # recherche de la localisation de la transaction
      localisation = DistanceMatrix::DistanceMatrix::pays(@ip)

      puts "demarrage du processus de paiement via le numéro de téléphone ..."
      puts "recherche de l'existance du payeur ..."
      if Customer.exists?(authentication_token: @customer_token)
        # customer has been found on API plateform, we can get his data
        # check is customer and merchant are differents
        puts "Authenticate customer in progress .."
        customer = Customer.find_by_authentication_token(@customer_token)
        if customer && customer.valid_password?(@customer_password)
          # customer has been authenticate, searchin new phone
          # on verifie qu'il s'agit bien d'un numéro du Cameroun
          if !is_customer_different?(customer.phone, @merchant_phone)
            # searching if customer phone and merchant phone are different
            return false, "Vous ne pouvez pas vous payer à vous même!"
          else
            puts "Vérification si le nnuméro de téléphone est camerounais ..."
            if Parametre::PersonalData::numeroCameroun(@merchant_phone)

              puts "Numéro de téléphone camerounais trouvé"

              if Customer.exists?(phone: @merchant_phone)

                puts "Ce marchand existe deja dans la base de données"

                # verification que le montant est suffisant dans le compte utilisateur
                if have_amount?(customer.id, @amount)

                  if customer.account.update(amount: customer.account.amount.to_f - @amount.to_f)

                    # recherche le compte du client
                    # m_account = Customer.find_by_phone(@merchant_phone).account
                    m_customer = Customer.find_by_phone(@merchant_phone)

                    # trigger result for merchant
                    # if m_account.blank?
                    if !Account.exists?(customer_id: m_customer.id)
                      return false, "Compte inexistant"
                    else
                      m_account = Customer.find_by_phone(@merchant_phone).account
                      if m_account.update(amount: m_account.amount.to_f + @amount.to_f)
                        marchant = History.new(
                          customer_id: Customer.find_by_phone(@merchant_phone).id,
                          amount: @amount,
                          context: 'phone',
                          flag: 'encaissement'.upcase,
                          code: "EXT_PAY_#{@hash}",
                          region: localisation
                        )
    
                        if marchant.save

                          puts "Enregistrement de l'historique du marchand ..."
    
                          client = History.new(
                            customer_id: customer.id,
                            amount: Parametre::Parametre::agis_percentage(@amount),
                            context: 'phone',
                            flag: 'paiement'.upcase,
                            code: "EXT_PAY_#{@hash}",
                            region: localisation
                          )
    
                          if client.save
                            puts "Enregistrement de l'historique du client ..."

                            Sms.nexah(@merchant_phone, "Bonjour, un Paiement d'un montant de #{@amount} F CFA vient d'etre effectué dans votre compte #{@merchant_phone}. ID transaction EXT_PAY_#{@hash}. Vous avez maintenant #{m_account.amount} F CFA dans votre compte. Rapprochez-vous d'un partenaire Afriland First Bank ou creer un compte PAYMEQUICK.")

                            return true, {
                                amount: @amount,
                                device: 'XAF',
                                frais: Parametre::Parametre::agis_percentage(@amount).to_f - @amount.to_f,
                                total: Parametre::Parametre::agis_percentage(@amount).to_f.round(2),
                                receiver: @merchant_phone, # retourne ne numero de l'utilisateur inconnu Customer.find_by_phone(@merchant_phone).complete_name,
                                nexah: Customer.find_by_authentication_token(@customer_token).complete_name,
                                date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                                status: "PAIEMENT EFFECTUÉ"
                            }
                            
                          else
    
                            # Notify admin for this errors
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
                    end

                  else

                    Rails::logger::info "Impossible de mettre a jour les informations du client"
                    return false, "Impossible de mettre à jour les informations du client"

                  end

                else

                  return false, "Montant insuffisant dans le compte pour effectuer la transaction"


                end
                
    
              else
                puts "Nouveau numéro decouvert"

                # verification du solde dans le compte du payeur
                puts "Vérification du solde payeur"

                if have_amount?(customer.id, @amount)

                  # enregistrement du nouveau numero dans la plateforme
                  new_merchant = Customer.new(
                    email: Faker::Internet.email,
                    password: 123456, #Faker::Internet.password,
                    name: Faker::Name.first_name,
                    second_name: Faker::Name.last_name,
                    phone: @merchant_phone,
                    cni: Faker::Code.imei,
                    type_id: 11,
                    sexe: Faker::Gender.binary_type
                  )

                  #trying to save new demo customer
                  if new_merchant.save
                    #update payer account amount
                    @current_amount = debit_customer_account(customer.id, @amount)

                    if @current_amount[0]
                      puts "Save new merchant informations with informations : #{new_merchant.as_json}"
                      #trying to create new_merchant account and store data amount
                      new_merchant_account = Account.new(
                        customer_id: new_merchant.id,
                        amount: @amount
                      )

                      # creating account
                      if new_merchant_account.save
                        puts "Creation du compte financier du nouveau marchand effectué avec pour données : #{new_merchant_account}"

                        client = History.new(
                          customer_id: customer.id,
                          amount: Parametre::Parametre::agis_percentage(@amount),
                          context: 'phone',
                          flag: 'paiement'.upcase,
                          code: "EXT_PAY_#{@hash}",
                          region: localisation
                        )

                        # Historique du client
                        if client.save
                          puts "Creation de l'historique du payeur : #{client}"
                          
                          # Historique du marchand virtuel pour le moment
                          marchand = History.new(
                            customer_id: new_merchant.id,
                            amount: @amount,
                            context: 'phone',
                            flag: 'paiement'.upcase,
                            code: "EXT_PAY_#{@hash}",
                            region: localisation
                          )

                          if marchand.save
                            puts "Journalisation des informations du nouveau marchand avec pour données : #{marchand.as_json}"

                            puts "Save new merchant account information"
                            Sms.nexah(@merchant_phone, "Bonjour, ca y est votre compte est crée, #{new_merchant.code} est votre code. Paiement reçu de #{@amount} F CFA dans votre numéro de telephone #{@merchant_phone}. ID EXT_PAY_#{@hash}. Details : https://payquick-develop.herokuapp.com/webview/#{@hash}/#{marchand.id}.")

                            #Envoi d'une push notification au marchand
                            OneSignal::OneSignalSend.genericOneSignal(@playerID, "#{Client.prettyCallSexe(customer.sexe)} #{customer.complete_name} Vous venez d'effectuer une paiement de #{@amount} FC, votre compte a été débité de #{Parametre::Parametre::agis_percentage(@amount).to_f.round(2)} FC incluant les frais de #{Parametre::Parametre::agis_percentage(@amount).to_f - @amount.to_f} FC. Votre solde est de #{customer.account.amount} FC")

                            return true, {
                                amount: Parametre::Parametre::agis_percentage(@amount).to_f.round(2), #@amount,
                                device: 'CFA',
                                frais: (Parametre::Parametre::agis_percentage(@amount).to_f - @amount.to_f).round(2),
                                total: Parametre::Parametre::agis_percentage(@amount).to_f.round(2),
                                receiver: @merchant_phone, # retourne ne numero de l'utilisateur inconnu Customer.find_by_phone(@merchant_phone).complete_name,
                                payeur: Customer.find_by_authentication_token(@customer_token).complete_name,
                                date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                                status: "PAIEMENT EFFECTUÉ"
                            } #"Paiement effectué d'un montant de #{Parametre::Parametre::agis_percentage(@amount)} à #{@merchant_phone}"

                          else

                            return false, "Impossible de mettre à jour l'historique du marchand virtuel : #{marchand.errors.full_messages}"

                          end
                        else

                          return false, "Impossible de mettre a jour l'historique du payeur/Client : #{client.errors.full_messages}"

                        end
                      end
                    else
                      return @current_amount[1]
                    end
                  else
                    # retourne des erreurs s'ils en existe
                    puts new_merchant.errors.full_messages
                  end

                else

                  return false, "Montant insuffisant dans le compte pour effectuer la transaction"

                end
              end

            else

              return false, "Ce numéro #{@merchant_phone} est invalide, il n'est pas au format du Cameroun. Merci de le corriger et de réessayer!"

            end
          end
        else
          # customerhas not be authenticate
          puts "Impossible d'authentifier cet utilisateur pour cette transaction"
          return false, "Echec d'authentification, Numéro de téléphone ou mot de passe invalide."
        end
      end

    end

    # @api External::DemoUsers.Payment(argv)
    # @author mvondoyannick@gmail.com
    # @param [Object] argv
    def self.Payment(argv)
      @customer_token = argv[:token]
      @customer_password = argv[:password]
      @merchant_phone = argv[:phone]
      @amount = argv[:amount]
      @hash = rand(11**11)
      @ip = argv[:ip]
      @playerID = argv[:oneSignalID]

      # get data geolocation from IP transaction
      # TODO replace IP geolocation with lat/lon geolocation datas
      adress = DistanceMatrix::DistanceMatrix::pays(@ip)

      puts "Starting phone payement ..."

      puts "Verifiying Account customer #{@customer_token} amount ..."

      # Recherche le customer pour authentification
      customer = Customer.find_by_authentication_token(@customer_token)
      if customer && customer.valid_password?(@customer_password)

        puts "Customer/Payer found and all his data are ok ..."

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
                puts "Merchant phone don't found inside the plateforme..."
                # on n'a pas trouver le marchand, on le cree directement et on credit son compte puis le le notifie par SMS
                new_merchant = Customer.new(
                  email: Faker::Internet.email,
                  password: 123456, #Faker::Internet.password,
                  name: Faker::Name.first_name,
                  second_name: Faker::Name.last_name,
                  phone: @merchant_phone,
                  cni: Faker::Code.imei,
                  type_id: 2,
                  sexe: Faker::Gender.binary_type
                )

                #trying to save new demo customer
                if new_merchant.save
                  puts "Save new merchant informations DB."
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

                        puts "Save new merchant account information"
                        Sms.nexah(@merchant_phone, "Vous venez de recevoir un Paiement de #{@amount} F CFA dans votre numéro de telephone #{@merchant_phone}. ID EXT_PAY_#{@hash}. Details : https://payquick-develop.herokuapp.com/webview/#{@hash}/#{marchand.id}.")

                        #Envoi d'une push notification au marchand
                        OneSignal::OneSignalSend.genericOneSignal(@playerID, "#{Client.prettyCallSexe(customer.sexe)} #{customer.complete_name} Vous venez d'effectuer une paiement de #{@amount} FC, votre compte a été débité de #{Parametre::Parametre::agis_percentage(@amount).to_f.round(2)} FC incluant les frais de #{Parametre::Parametre::agis_percentage(@amount).to_f - @amount.to_f} FC. Votre solde est de #{customer.account.amount} FC")

                        return true, {
                            amount: @amount,
                            device: 'FC',
                            frais: Parametre::Parametre::agis_percentage(@amount).to_f - @amount.to_f,
                            total: Parametre::Parametre::agis_percentage(@amount).to_f.round(2),
                            receiver: @merchant_phone, # retourne ne numero de l'utilisateur inconnu Customer.find_by_phone(@merchant_phone).complete_name,
                            nexah: Customer.find_by_authentication_token(@customer_token).complete_name,
                            date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                            status: "PAIEMENT EFFECTUÉ"
                        } #"Paiement effectué d'un montant de #{Parametre::Parametre::agis_percentage(@amount)} à #{@merchant_phone}"

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
                puts "This merchant phone exist in the DB ... and data are #{customer.as_json}"
                if customer.account.update(amount: customer.account.amount.to_f - @amount.to_f)

                  m_account = Customer.find_by_phone(@merchant_phone).account

                  # trigger result for merchant
                  if m_account.blank?
                    return false, "Compte inexistant"
                  else
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
                          Sms.nexah(@merchant_phone, "Bonjour, un Paiement d'un montant de #{@amount} F CFA vient d etre effectue dans votre compte #{@merchant_phone}. ID transaction EXT_PAY_#{@hash}. Le solde de votre compte est maintenant de #{m_account.amount} F CFA. Rapprochez-vous d'une agence UBA ou creer un compte PayMeQuick.")
                          return true, {
                              amount: @amount,
                              device: 'XAF',
                              frais: Parametre::Parametre::agis_percentage(@amount).to_f - @amount.to_f,
                              total: Parametre::Parametre::agis_percentage(@amount).to_f.round(2),
                              receiver: @merchant_phone, # retourne ne numero de l'utilisateur inconnu Customer.find_by_phone(@merchant_phone).complete_name,
                              nexah: Customer.find_by_authentication_token(@customer_token).complete_name,
                              date: Time.now.strftime("%d-%m-%Y, %Hh:%M"),
                              status: "PAIEMENT EFFECTUÉ"
                          }#,"Paiement d'un montant de #{Parametre::Parametre::agis_percentage(@amount)} F CFA effectué au  #{@merchant_phone}."
                        else
  
                          # Notify admin for this errors
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