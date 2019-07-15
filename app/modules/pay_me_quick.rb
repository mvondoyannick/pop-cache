module PayMeQuick
    class Charge
        def initialize(args)
            $argv = args
        end

        # Permet de débiter le compte de l'utilisateur payeur
        # @param argv [Object] 
        def self.Create(argv)
            
        end
    end


    class Customer

    end

    # @presentation Class to make payment
    # @method PayMeQuick::Pay.Create(payeur: @payeur, marchand: @marchand, amount: @amount, password: @password, )
    # @param [Object] nothing
    class Pay

        def initialize(argv)

        end

        def self.Create(argv)
          @payeur = argv[:payeur]
          @marchand = argv[:marchand]
          @amount = argv[:amount]
          @password = argv[:password]
          @ip = argv[:ip]
          @playerId = argv[:playerId]
          @lat = argv[:lat]
          @lon = argv[:lon]

          begin

            if @marchand == @payeur
              Rails::logger::info "Numéro indentique, transaction annuler!"
              return false, " Vous ne pouvez pas vous payer à vous même!"
            else

              marchand = Customer.find_by_phone(@marchand) #personne qui recoit
              marchand_account =  marchand.account #Account.where(customer_id: marchand.id).first #le montant de la personne qui recoit
              client = Customer.find_by_phone(@payeur) #la personne qui envoi
              client_account = client.account #Account.where(customer_id: client.id).first # le montant de la personne qui envoi

              if client.valid_password?(@client_password)
                Rails::logger::info "Client identifié avec succes!"

                #contrainte si le montant depasse 150 000 F CFA XAF
                if @amount > $limit_amount
                  Rails::logger::info "Limite de transaction de 150 000 F depassée"
                  return false, "Vous ne pouvez pas faire une transaction au dela de #{$limit_amount} #{$devise}."
                else
                  if client_account.amount.to_f >= Parametre::Parametre::agis_percentage(@amount) #@amount.to_i
                    Rails::logger::info "Le montant est suffisant dans le compte du client, transaction possible!"
                    @hash = "PP_#{SecureRandom.hex(13).upcase}"
                    client_account.amount = Parametre::Parametre::soldeTest(client_account.amount, amount) #client_account.amount.to_f - Parametre::Parametre::agis_percentage(@amount).to_f #@amount
                    if client_account.save
                      Rails::logger::info "Solde tm : #{client_account.amount.to_f}"
                      marchand_account.amount += @amount

                      #on historise la transaction
                      #saveHistory(@to, @hash,"ENCAISSEMENT","none",@amount,nil ,nil ,nil )
                      marchant = History.new(
                          customer: @to,
                          code: @hash,
                          flag: "encaissement".upcase,
                          context: "none",
                          # date: Time.now.strftime("%d-%m-%Y @ %H:%M:%S"),
                          amount: @amount, #Parametre::Parametre::agis_percentage(@amount)
                          ip: @ip,
                          lat: @lat,
                          long: @lon,
                          region: Geocoder.search([@lat, @lon]).first.address
                      )

                      #on enregistre
                      marchant.save

                      if marchand_account.save
                        #envoi d'une notification OneSignal
                        Sms.new(marchand.phone, "Paiement recu. Montant :  #{@amount.round(2)} F CFA XAF, \t Payeur : #{prettyCallSexe(client.sexe)} #{client.name} #{client.second_name if !client.second_name.nil?}. Votre nouveau solde:  #{marchand_account.amount} F CFA XAF. Transaction ID : #{@hash}. Date : #{Time.now}. #{$signature}")
                        Sms::send
                        #--------------------------------------------------
                        # push notificatin au marchand
                        OneSignal::OneSignalSend.sendNotification(@playerId, Parametre::Parametre.agis_percentage(@amount), "#{marchand.name} #{marchand.second_name}", "#{client.name} #{client.second_name}")
                        #Sms.new(client.phone, "Compte debite. Motif: Paiement effectue. Montant : #{Parametre::Parametre::agis_percentage(@amount)} F CFA XAF, Compte debite : #{prettyCallSexe(client.sexe)} #{client.name} #{client.second_name} (#{client.phone}). Nouveau solde : #{client_account.amount.round(2)} F CFA XAF. Transaction ID : #{@hash}. Date : #{Time.now} . #{$signature}")
                        #Sms::send
                        #----------------------------------------------------
                        Rails::logger::info "Paiement effectué de #{@amount} entre #{@from} et #{@to}."

                        #journalisation de l'historique

                        #on enregistre encore l'historique
                        #transaction = saveHistory(@from,@hash,"PAIEMENT","none",Parametre::Parametre::agis_percentage(@amount),nil,nil,nil )
                        transaction = History.new(
                            customer: @from,
                            code: @hash,
                            flag: "paiement".upcase,
                            context: "none",
                            date: Time.now.strftime("%d-%m-%Y @ %H:%M:%S"),
                            amount: Parametre::Parametre::agis_percentage(@amount),
                            ip: @ip
                        )

                        if transaction.save
                          Rails::logger::info "Transaction enregistrée avec succes"
                        end

                        #fin de journalisation

                        #enregistrement des commissions
                        Parametre::Parametre::commission(@hash, @amount, Parametre::Parametre::agis_percentage(@amount).to_f, (Parametre::Parametre::agis_percentage(@amount).to_f - @amount))
                        #fin d'enregistrement de la commission

                        return true, "Votre Paiement de #{@amount} F CFA vient de s'effectuer avec succes. \t Frais de commission : #{(Parametre::Parametre::agis_percentage(@amount).to_f - @amount).round(2)} F CFA. \t Total prelevé de votre compte : #{Parametre::Parametre::agis_percentage(@amount).to_f.round(2)} F CFA. \t Nouveau solde : #{client_account.amount.round(2)} #{$devise}."
                      else
                        Rails::logger::info "Marchand non credite de #{@amount}"
                        Sms.new(marchand.phone, "Impossible de crediter votre compte de #{amount}. Transaction annulee. #{$signature}")
                        Sms::send
                        return false
                      end
                    else
                      Rails::logger::info "Client non debite du montant #{@amount}"
                      Sms.new(client.phone, "Impossible d\n'acceder a votre compte. Transaction annulee. #{$signature}")
                      Sms::send
                      return false
                    end
                  else
                    Rails::logger::info "Le solde de votre compte est de : #{marchand_account.amount}. Paiment impossible"
                    OneSignal::OneSignalSend.montantInferieur(@playerId, "#{client.name} #{client.second_name}", amount)
                    #Sms.new(client.phone, "Le montant dans votre compte est inferieur a #{amount}. Transaction annulee. #{$signature}")
                    #Sms::send
                    return false, "Le solde de votre compte est insuffisant."
                  end
                end
              else
                Rails::logger::info "Invalid user password authentication"
                Sms.new(client.phone, "Mot de passe invalide. Transaction annulee. #{$signature}")
                Sms::send
                return false, "Mot de passe invalide."
              end
            end
          end

          rescue ActiveRecord::RecordNotFound

            Rails::logger::info "Impossible de trouver cet enregistrement"

        end
        
    end

    class Refunt

    end

    class Invoice

    end

    class Credit

      def self.Create(argv)
      end

    end

    class Debit

      def self.Debit(argc)
      end

    end

    class Balance

      def self.Get(argc)
      end

    end

    class Retrait

      def self.Create(argc)
      end

      def self.ChechExistingRetrait(argc)
      end

      # Cancel current retrait
      # @param [Object] argc
      def self.Cancel(argc)
        # .Cancel(phone: @phone, authorization: @authorization)
        return argc[:phone]
      end
      
    end
end