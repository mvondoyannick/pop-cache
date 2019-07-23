module Abonnements

  class Paliers

    # @param [String] name
    # @param [Integer] amount
    # @param [Integer] max_retrait
    def self.add(name, amount, max_retrait)
      @name         = name
      @amount       = amount
      @max_retrait  = max_retrait  #le retrait maximum que l'on peut effectuer dans ce palier

      query = Palier.new(
         name:        @name,
         amount:      @amount,
         max_retrait: @max_retrait
      )

      if query.save

        return true, "Saved new palier : #{query.as_json(only: [:name, :amount, :max_retrait])}"

      else

        return false, "Une erreur est survenue : #{query.errors.full_messages}"

      end

    end

    # DELETE Palier with some ID
    # @param [Integer] palier_id
    def self.delete(palier_id)

      @id     = palier_id

      begin

        query = Palier.find(@id)

        return true, "Le palier n° #{@id} vient d'etre supprimer" if query.destroy

      rescue ActiveRecord::RecordNotFound

        return false, "Le palier #{@id} semble etre inexistant"

      end
    end


    # Get customer current palier, sur la base de son abonnement
    def self.current(customer_id)
      @customer = customer_id

      #check customer
      customer = Customer.find(@customer)
      if customer.blank?

        return false, "CUSTOMER NOT FOUND", status: 404

      else

        #i suppose that customer has be found
        abonnement = Abonnement.find_
      end
    end


    #EDITE SAVE PALIER ON DB
    # TODO VERIFY AND VALIDATE THIS METHOD MODULE
    # @param [Object] args
    def self.edit(args)

      @id             = args[:id]
      @amount         = args[:amount]
      @max_retraint   = args[:retrait]

      if args.count != 3

        return false, "Wrong parameters"

      else

        begin
          #recherche du palier concerné
          palier = Palier.find(@id)

          #Update data information
          upPalier = palier.update(amount: @amount, max_retrait: @max_retrait)
          if upPalier

            return true, "Palier mis a jour!"

          else

            return false, "Impossible de mettre a jour ce palier : #{upPalier}"

          end

        rescue ActiveRecord::RecordNotFound

          return false, "Le Palier N° #{@id} semble ne pas exister"

      end

      end

    end

  end

  class Abonnements

    #Permet de lister tous les abonnements disponible
    def self.list

      content = Abonnement.all
      return true, content.as_json(only: [:palier_id, :customer_id, :date_debut, :date_fin])

    end


    #Add new abonnement
    # @param [Integer] palier_id
    # @param [Integer] customer_id
    def self.add(palier_id, customer_id)

      @palier_id    = palier_id
      @customer_id  = customer_id

      #Chech customer
      begin

          #debit customer account
          # et customer data
          customer = Customer.find(@customer_id)

          #get customer amount inside account
          customer_amount = customer.account.amount.to_f
          Rails::logger.info "Currement customer amount account #{customer_amount.to_f}"

          #Get palier coast
          palier_amount = Palier.find(@palier_id).amount.to_f

          Rails::logger.info "Updatign customer account debit palier"
          if customer_amount >= palier_amount

              Rails::logger.info "Customer account updated ..."

              #creating new abonnement
              #create new abonnement
              query = Abonnement.new(
                  palier_id:    @palier_id,
                  customer_id:  @customer_id,
                  date_debut:   Time.now,
                  date_fin:     30.days.from_now
              )

              if query.save

                #on deite effectivement le customer
                if customer.account.update(amount: (customer_amount - palier_amount))

                  #Adding transaction history
                  begin
                    #generate uniq token hash
                    @hash = SecureRandom.uuid.upcase

                    history = History.new(
                        customer_id: @customer_id,
                        code: "PMQ_AB_#{@hash}",
                        flag: "abonnement".upcase,
                        context: "MOBILE",
                        amount: palier_amount
                    )

                  #on enregistre
                  history.save

                  rescue ActiveRecord::RecordNotUnique

                    #on regenere le hash une fois de plus et on continu
                    Rails::logger.info "Le hash ne semble pas etre unique"

                    @hash = SecureRandom.hex(13).upcase

                    history = Transaction.new(
                        customer: @customer_id,
                        code: "PMQ_AB_#{@hash}",
                        flag: "abonnement".upcase,
                        context: "none",
                        date: Time.now.strftime("%d-%m-%Y @ %H:%M:%S"),
                        amount: palier_amount
                    )

                    history.save


                  end

                  #Notify customer with SMS
                  Sms.sender(Customer.find(@customer_id).phone, "Vous vener de vous abonner au palier #{Palier.find(@palier_id).name.upcase}, cela vous a coute #{Palier.find(@palier_id).amount} F CFA et vous permet de retirer un montant maximum #{Palier.find(@palier_id).max_retrait } F CFA. Date d'expiration : #{query.date_fin}. #{Client.appName}")

                  return true, "new abonnement added for customer #{customer.name}"

                else

                  return false, "Impossible de mettre a jours le compte client du customer!"

                end

              else

                return false, "Impossible d'enregistrer cet abonnement : #{query.errors.full_messages}"

              end

          else

            Sms.sender(customer.phone, "Votre solde est insuffisant pour effectuer cet abonnement, merci de recharger votre compte ! ")
            return false, "Solde client insuffisant"

          end

      rescue ActiveRecord::RecordNotFound

        return false, "Utilisateur inconnu, abonnement annulé"

      end

    end

    # Passer d'un Palier inferieur à un palier superieur, permet de faire une
    # evolution, tout en sachant que l'evolution est en avant ou en arriere
    # @param [String] palier_id
    # @param [String] customer_id
    def self.evolve(palier_id, customer_id)
      @palier       = Palier.find(palier_id).name
      @customer     = customer_id

      case @palier

      when "free"


      when "normal"


      else
        #return default free palier information

      end

    end

    #Search customer Abonnement
    # @param [Object] customer_id
    def self.search(customer_id)

      @customer_id = customer_id

      customer = Customer.find(@customer_id)
      if customer.blank?
        return false, "Utilisateur inconnu"
      else
        # customer has be found
        abonnement = Abonnement.find_by(customer_id: customer.id)
        if abonnement.blank?
          return false, "Aucun abonnement pour cet utilisateur"
        else
          palier = abonnement.palier.max_retrait
          if palier.blank?
            return false, "Aucun palier existant"
          else
            return true, palier
          end
        end
      end
    end

  end
end