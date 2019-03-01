class Client
  $signature = "POP-CASH"
  $limit_amount = 100000
  $limit_day_transaction = 100
  $devise = "F CFA"
  $status = {
    false: :false
  }

  require 'securerandom'
  #require 'activerecord'

    def initialize(from, to, amount, pwd)
      $from = from
      $to = to 
      $amount = amount 
      $pwd = pwd
    end


    def self.create_user(name, second_name, phone, password)
      @name = name
      @second_name = second_name
      @phone = phone
      #@cni = cni
      @email = "#{SecureRandom.hex(3)}@pop-cash.cm"
      @password = password #"PC_#{SecureRandom.hex(4).upcase}"

      #creation du compte de l'utilisateur
      customer = Customer.new(
        name: @name,
        second_name: @second_name,
        phone: @phone,
        email: @email,
        password: @password
      )

      if customer.save
        Sms.new(@phone, "Mr/Mme #{@name} #{@second_name} votre compte a ete cree avec succes .Bienvenue sur #{$signature}")
        Sms::send
        create_user_account(customer.id, customer.phone)

        #generation de 2Fa
        auth = Parametre::Authentication::auth_two_factor(@phone, 'context')
        if auth[0] == true
          return true, @phone
        else
          return auth[1]
        end
      else
        Sms.new(@phone, "Impossible de creer Votre profil personnel, merci de vous rappocher d\'un service Express Union. #{$signature}")
        Sms::send
        puts customer.errors.messages
        return "Echec de creation du profil personnel. code erreurs : #{customer.errors.messages}"
      end
    end

    #creation du compte utilisateur
    def self.create_user_account(id, phone)
      @id = id
      @phone = phone
      customer_account = Account.new(
        amount: 5000,
        customer_id: @id
      )
      
      if customer_account.save
        Sms.new(@phone, "Votre porte monnaie virtuel vient d\'etre cree, il dispose d\'une somme de 5000 #{$devise}. #{$signature}")
        Sms::send
        return "creation porte-monnaie succes"
      else
        Sms.new(@phone, "Impossible de creer Votre porte-monnaie virtuel, merci de vous rappocher d\'un service Express Union. #{$signature}")
        Sms::send
        return "Creation porte-monnaie failed"
      end
    end


    #permet de crediter le compte utilisateur en se basant sur son numero de telephone et sur le montant
    def self.credit_account(phone, amount)
      @phone = phone
      @amount = amount

      #on rechercher le user pour avoir sont ID
      customer = Customer.where(phone: @phone).first
      if customer.blank?
        return false, "Aucune utilisateur ne correspond."
      else
          customer_account = Account.where(customer_id: customer.id).first
          if customer_account.blank?
            return false, "Auccun compte correspondant trouve."
          else
            customer_account.amount = customer_account.amount.to_i + @amount.to_i
            if customer_account.save
              hash = SecureRandom.hex(13).upcase
              Sms.new(@phone, "Mr/Mme #{customer.name} #{customer.second_name}, vous venez d\'etre crediter d'un montant de #{@amount} #{$devise}, le solde de votre compte est de #{customer_account.amount} #{$devise}. ID Transaction : #{hash}. #{$signature}")
              Sms::send
              return "Le compte a ete credite d\'un montant de #{@amount}'."
            else
              Sms.new(@phone, "Mr/Mme #{customer.name} #{customer.second_name}, impossible de crediter votre compte. Echec de la Transaction #{hash}. #{$signature}")
              Sms::send
              return "impossible de crediter le compte. code erreurs : #{customer_account.errors}"
            end
          end  
      end
  end

    #authenticationof user
    def self.auth_user(phone, password)
      @phone = phone
      @password = password

      customer = Customer.where(phone: @phone).first
      if !customer.blank?
        if customer.valid_password?(@password)
          puts "Utilsateur #{customer.name} connecté", customer.as_json(only: [:id, :phone, :name, :second_name])
          return customer.as_json(only: [:id, :phone, :name, :second_name]), status: :created
        else
          puts "Impossible de connecter utilsateur #{customer.name}"
          return false
        end
      else
        puts "Utilsateur inconnu"
        #raise customer, "Errors"
        return false
      end
    end

    def self.get_balance(phone, password)
      @phone = phone
      @password = password

      #on recherche le client
      query = Customer.where(phone: phone).first
      if query.blank?
        return false, "Utilisateur inconnu."
      else
        if query.valid_password?(@password)
          account = Account.where(customer_id: query.id).first
          if account.blank?
            return false, "Aucun compte utilisateur correcpondant ou compte vide"
          else
            Sms.new(@phone, "Mr/Mme #{query.name} #{query.second_name}, le solde de votre compte est : #{account.amount} #{$devise}. #{$signature}")
            Sms::send
            return true,"Mr/Mme #{query.name} #{query.second_name}, le solde de votre compte est : #{account.amount} #{$devise}. #{$signature}"
          end
        else
          return false,  "Mot de passe invalide. #{$signature}"
        end
      end
    end


    #permet de mettre a jour le montant des comptes
    def self.update_account_client(id, amount)
        @id = id
        @amount = amount

        response = Account.find(@id)
        if !response.blank?
          response.amount = response.amount - @amount
          if response.save
            return true
          else
            return "failed"
          end
        else
          return false
        end
    end


    #permet de mettre a jour le montant des comptes marchand
    def self.update_account_marchand(id, amount)
        @id = id
        @amount = amount

        response = Account.find(@id)
        if !response.blank?
          response.amount = response.amount + @amount
          if response.save
            return true
          else
            return "failed"
          end
        else
          return false
        end
    end


    #recherche les informations sur l'emeteur de la requete de paiement
    def self.find_client(id)
      @sender_id = id
      query = Customer.find(id)
      if query.blank?
        return false, "Utilisateur inconnu"
      else
        return true, query
      end
    end

    #recherche les informations sur le receveur
    def self.find_marchand(id)
      @receiver_id = id
      query = Customer.find(id)
      if query.blank?
        return false, "Utilisateur inconnu"
      else
        return true, query
      end
    end

    #pour debiter de l'argent dans le compte du client
    def debit_client(id, amount, signature)
      @id = id
      @amount = amount
      @signature = signature

      response = find_client(id)
      if response

      end
    end

    #debiter le compte utilisateur durant un retrait
    def self.debit_user_account(phone, amount)
      @phone = phone
      @amount = amount

      customer = Customer.where(phone: @phone).first
      account = Account.where(customer_id: customer.id).first
      a = account.amount.to_i - @amount.to_i
      puts a
      puts "Compte client : #{account.amount}"
      if account.update(customer_id: customer.id, amount: a )
        return true
      end
    end



    #validation du retrait par l'utilisateur/customer
    def self.validate_retrait(phone, pwd)
      @phone  = phone
      @pwd    = pwd

      customer = Customer.where(phone: @phone).first
      if customer && customer.valid_password?(@pwd)
        #on mets a jour les informations sur await sur customer
        await = Await.where(customer_id: customer.id).first
        if customer.update(await: nil)
          #on debit le compte le client
          debit_client = debit_user_account(@phone, await.amount)
          if debit_client && await.destroy
            Sms.new(@phone, "Vous venez de retirer #{await.amount} #{$devise} de votre compte. #{$signature}")
            Sms::send
            puts "Retrait effectué"
            return true, "Retrait de #{await.amount} #{$devise} effectué sur le compte #{@phone}. #{$signature}"
          else
            puts "Impossible de retirer de l argent dans ce compte"
            return false, "retrait argent impossible. merci de contacter le service client au 007"
          end
        else
          puts "Impossible de mettre a jour les informations utilisateur"
          return false, "Impossible de communiquer avec l IA d AGIS"
        end
      else
        puts "Mot de passe invalide"
        return false, "Invalid password"
      end
    end

    #permet de verifier qu'il ya un retrait en cours pour un numero de telephone/customer
    def self.check_retrait(phone)
      @phone = phone
      customer = Customer.where(phone: phone).first
      await = Await.where(customer_id: customer.id, id: customer.await).first
      if await
        return true, await.as_json(only: [:amount, :created_at])
      else
        return false, "Aucun retrait en cours pour ce compte (#{@phone})"
      end
    end

    def self.get_balance_retrait(phone, amount_retrait)
      @phone = phone
      @amount = amount_retrait
      customer = Customer.where(phone: @phone).first
      customer_amount = Account.where(customer_id: customer.id).first.amount
      if customer
        if customer_amount.to_i > @amount.to_i 
          puts "Il a de l argent"
          return true
        else
          Sms.new(@phone, "Le montant de votre compte est insuffisant. #{$signature}")
          Sms::send
          puts "Pas assez d argent dans le compte #{@phone}"
          return false
        end
      else
        return false, "Impossbile de verifier cet utilisateur"
      end
    end


    #permet d'initialiser une procedure de retrait du coté de l'agent EU 
    def self.init_retrait(phone, amount)
      @phone = phone
      @amount = amount.to_i
      #se trouve dans la table retrait_await, on ajout un marqueur au client
      customer = Customer.where(phone: @phone).first
      if get_balance_retrait(@phone, @amount) == true
        if customer.await.nil?
          #on creet un nouvel await
          await = Await.new(
            amount: @amount,
            customer_id: customer.id
          )
          if await.save
            #mise a jour du montant du customer
            account = Account.where(customer_id: customer.id).first
            customer_amount = account.amount - @amount
            
            #on mets a jour la table customer sur await
            if customer.update(await: await.id) && account.update(amount: customer_amount)
              #---------------send sms to customer--------------
              Sms.new(@phone, "Vous allez effectuer un retrait d un montant de #{@amount} #{$devise}. #{$signature}")
              Sms::send
              puts "user await updated"
              return true, "processus initialise avec succes pour le numero #{@phone}"
            else
              puts "user await canceled"
              return false, "Impossible d\'initialiser le processus de retrait. Error : #{customer.errors.messages}'"
            end
            puts "created new await"
            return true, "nouveau await cree"
          else
            puts "error creating await"
            return false, "Impossible de creer await"
          end
        else
          #le client n'est pas disponible sur la plateforme
          return false, "Utilisateur inconnu ou disposant deja "
        end
      else
        return false, "Ce compte ne dispose pas assez d argent"
      end
        
    end


    #pour crediter le compte du marchand
    def credit_marchand(id, amount, signature)

    end

    def self.pay(from, to, amount, pwd)
      @from = from.to_i
      @to = to.to_i
      @amount = amount.to_i  #montant de la transation
      @client_password = pwd

      puts "Client : #{@from} -- marchand : #{@to} -- Amount : #{@amount} -- pwd : #{@client_password}"

      marchand = Customer.where(phone: @to).first                         #personne qui recoit
      puts marchand
      marchand_account = Account.where(customer_id: marchand.id).first    #le montant de la personne qui recoit
      client = Customer.where(phone: @from).first                         #la personne qui envoi
      client_account = Account.where(customer_id: client.id).first        # le montant de la personne qui envoi

      if @from == @to
        Sms.new(@from, "Les numeros sont identiques, merci de les changer. Transaction annulee. #{$signature}")
        Sms::send
        puts "Numero indentique"
        return false, " Les numéros de transaction sont identique", $signature
      else
        if client.valid_password?(@client_password)
          puts "le client a le bon mot de passe"
          if client_account.amount.to_i >= Parametre::Parametre::agis_percentage(@amount) #@amount.to_i
            puts "le client a suffisament d'argent dans son compte"
            hash = SecureRandom.hex(13).upcase
            client_account.amount = client_account.amount.to_i - Parametre::Parametre::agis_percentage(@amount) #@amount
            if client_account.save
              marchand_account.amount = marchand_account.amount + Parametre::Parametre::agis_percentage(@amount) #@amount
              if marchand_account.save
                Sms.new(@to, "Vous avez recu un paiement d un montant de #{@amount} F CFA provenant de Mr/Mme #{client.name} #{client.second_name}. La transaction c\'est correctement terminee. Votre solde est maintenant de #{marchand_account.amount} F CFA. ID Transaction : #{hash}. #{$signature}")
                Sms::send
                #--------------------------------------------------
                Sms.new(@from, "Mr/Mme #{client.name} #{client.second_name}, #{Parametre::Parametre::agis_percentage(@amount)} F CFA ont ete debite de votre compte, le solde actuel de votre compte est #{client_account.amount} F CFA. ID Transaction : #{hash}. Merci de nous faire confiance. #{$signature}")
                Sms::send
                #----------------------------------------------------
                puts "Paiement effectué de #{@amount}"
                return true#, "Paiement effectué avec succes"
              else
                puts "Marchand non credite de #{@amount}"
                Sms.new(@to, "Impossible de crediter votre compte de #{amount}. Transaction annulee. #{$signature}")
                Sms::send
                return false
              end
            else
              puts "Client non debite du montant #{@amount}"
              Sms.new(@form, "Impossible d\'acceder a votre compte. Transaction annulee. #{$signature}")
              Sms::send
              return false
            end
          else
            puts "Le solde de votre compte est de : #{marchand_account.amount}. Paiment impossible"
            Sms.new(@form, "Le montant dans votre compte est inferieur a #{amount}. Transaction annulee. #{$signature}")
            Sms::send
            return false
          end
        else
          puts "Invalid password aythentication"
          Sms.new(@form, "Mot de passe invalide. Transaction annulee. #{$signature}")
          Sms::send
          return false
        end
      end
    end

    def self.transfert(from, to, amount, password)
      @from = from
      @to = to
      @amount = amount
      @client_password = password
      if (@from == @to)
        Sms.new(@from, "Expediteur et Receveur ne peuvent etre identique, merci de changer. #{$signature}")
        Sms::send
        return "#{@from} et #{@to} ne peuvent etre indentique. #{$signature}"
      else
        #on commernce par rechercher si le receveur appartient au reseaux
        marchand = Customer.where(phone: @to).first                           #personne qui recoit
        marchand_account = Account.where(customer_id: marchand.id).first      #le montant de la personne qui recoit
        client = Customer.where(phone: @from).first                           #la personne qui envoi
        client_account = Account.where(customer_id: client.id)                # le montant de la personne qui envoi
        #on authentifie le client a l'aide de son telephone et de son password
        if client.valid_password?(@client_password)
          if (client_account.amount >= @amount)
            hash = SecureRandom.hex(13).upcase
            marchand_account.amount = marchand_account.amount + @amount
            if marchand_account.save
              client_account.amount = client_account.amount - @amount
              if client_account.save
                Sms.new(@to, "Le paiement du montant #{@amount} F CFA provenant de #{client.name} #{client.second_name} c est correctement deroule. Votre solde est maintenant de #{marchand_account.amount} F CFA. ID Transaction : #{hash}. #{$signature}")
                Sms::send
                #----------------------------------
                Sms.new(@from, "Mr/Mme #{client.name} #{client.second_name}, #{@amount} F CFA ont ete debite de votre compte, le solde actuel de votre compte est #{client_account.amount} F CFA. ID Transaction : #{hash}. #{$signature}")
                Sms::send
                return "Le paiement du montant #{@amount} F CFA provenant de #{client.name} #{client.second_name} c est correctement deroule. ID Transaction : #{hash}. #{$signature}"
              else
                return "Echec du paiement du montant #{@amount} F CFA. Echec de la transaction ID Transaction : #{hash}. #{$signature}"
              end
            else
              return "une erreur est survenue durant le traitement"
            end
            else
              Sms.new(@from, "Montant du compte insuffisant. #{$signature}")
              return "Impossible d'effectuer le transfert, le montant est insuffisant"
          end
        else
          Sms.new(@from, "Transaction annulee, mot de passe invalide. #{$signature}")
          Sms::send
        end
      end
    end
end