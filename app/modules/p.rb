module P

  class Authenticate

    def initialize(arg)
      $email      = arg[:email]
      $password   = arg[:password]
    end

    #permet de rechercher une entreprise
    def self.is_user_exist?
        #@token          = token

        query = Agent.find_for_authentication(@name)
        if query.blank?
            return false
        else
            return true
        end
    end

    def self.new_customer(name, second_name, phone, cni, agent_id)
      @name           = name
      @second_name    = second_name
      @phone          = phone
      @cni            = cni
      @agent_id       = agent_id

      #on commence par recherche l'agent en question
      agent = Partenaire.find(@agent_id)
      if agent.blank?
        return false, "partenaire inconnu"
      else
        #on debute la requet d'insertion et de creation
        customer = Client::signup(@name, @second_name, @phone, @cni, "123456", nil, nil, nil, nil, nil)
        if customer[0]
          #on renvoi un mot de passe via le numero de la personne via SMS
          Sms.new(@phone, "Votre mot de passe est #{rand(5**5)}")
          return true, "customer will receive a notificationi"
        else
          return false, "Impossible de creer ce customer : #{customer.errors.full_messages}"
        end
      end

    end

    #permet de verifier le partenaire en question avant de faire toute operation
    # @param [Object] partner_id
    def self.partner_verify(partner_id)
      @partner_id     = partner_id

      #partner = Partenaire.find(@partner_id)
      return true
    end

    #creation d'un customer par un partenaire
    # @param [Object] name
    # @param [Object] second_name
    # @param [Object] phone
    # @param [Object] cni
    # @param [Object] partner_id
    def self.partner_customer(name, second_name, phone, cni, sexe)
      @name           = name
      @second_name    = second_name
      @phone          = phone
      @cni            = cni
      @sexe           = sexe
      #@partner        = partner_id
      @password       = 123456
      @email          = "#{rand(6**6)}@#{Client.appName}-cm.com"

      #check patner
      partner = partner_verify(@partner)
      if partner
        #on commence l'enregistrement du client car le partenaire a été identifier
        customer = Customer.new(email: @email, name: @name, second_name: @second_name, phone: @phone, two_fa: "authenticate", cni: @cni, password: @password, type_id: 1, sexe: @sexe)
        if customer.save
          #on enregistre la liaison entre le partenaire et le customer
          link = true #PartnerCustomer.new(customer_id: customer.id, partenaire_id: partner_id)
          if link
            #on notifi le client avec son mot de passe
            Sms.new(@phone, "Mr/Mme #{customer.name} #{customer.second_name}, heureux de vous accueillir sur #{Client.appName}, vous etes desormais inscrit sur #{Client.appName} et vous aussi vous pouvez faire des choses extraordinaire! votre mot de passe par defaut est #{@password}, pensez a le changer des que possible.")
            Sms.send
            return true, "Utilisateur enregistré"
          else
            Rails::logger::info "Des erreurs sont survenues " #link.errors.full_messages
          end
        else
          Rails::logger::info customer.errors.full_messages
          return false, customer.errors.full_messages
        end
      else
        #on ne reconnais pas le partenaire
        Rails::logger::info "Partenaire inconnu"
        return false, "Partnaire inconnu"
      end
    end


    #permet de verifier qu'en entreprise existe
    # @param [Object] name
    # @return [Object]
    def self.is_enterprise_exist?(name) 
        @name           = name
    end

    #Authentification sur la plateforme
    # @param [Object] email
    # @param [Object] password
    # @return [Object]
    def self.signied(email, password) 
      @email       = email 
      @password   = password
      #On recherche l'enregistrement correspondant
      agent = Agent.find_by_email(@email)
      if agent.blank?
          #Rails::Logger::info "Impossible de trouver ce partenaire"
          return false, "Utilisateur inconnu"
      else
          if agent.valid_password?(@password)
              return true, agent.as_json(only: [:name, :prenom, :email, :role_id, :id, :authentication_token])
          else
              return false, "Mot de passe inconnnu"
          end
      end
    end

    #Creation de compte sur la plateforme
    # @param [Object] name
    # @param [Object] second_name
    # @param [Object] sexe
    # @param [Object] phone
    # @param [Object] email
    # @param [Object] enterprise_name
    # @param [Object] password
    # @param [Object] document
    def self.signup(name, second_name, sexe, phone, email, enterprise_name, password, document) 
        @name               = name
        @second_name        = second_name
        @sexe               = sexe
        @phone              = phone
        @email              = email
        @enterprise_name    = enterprise_name
        @password           = password
        @document           = document


    end

    #Gestion de la structure
    def self.create_structure(name, phone, logo, rccm, location)
        @name               = name
        @logo               = logo
        @rccm               = rccm
        @location           = location

        #recherche sur l'utilisation d'activeStorage dans un module

        structure = Structure.new(structure_params)
        if structure.save
            return true, "Entreprise enregistrée"
        else
            return false, "Impossible d'entregistrer cet entreprise : #{structure.errors.messages}"
        end


        private
        def struture_params
            params.require(:strcture).permot(:name, :phone, :logo, :rccm, :location)
        end
    end

    #Bloquer un agent
    def self.lock(token, motif)
        @token      = token
        @motif      = motif



    end

    #Debloquer un agent
    def self.unlock

    end

  end

  class Authorize

    def initialize

    end

    #autoriser un client ou un guichet
    def self.authorize

    end

  end

  class Search

    def initialize

    end

    #Rechercher un guichet
    def self.searchGuichet

    end

    #rechercher un operateur de la plateforme
    def self.searchOperator

    end

  end

  #Gestion des guichets
  class Guichet

    def initialize

    end

    #Creation d'un nouveau guichet
    def self.create

    end

    #Bloquer une guichet
    def self.lock

    end

    #Debloquer un guichet
    def self.unlock

    end

    #Destruction d'un guichet
    def self.delete

    end

    #Editer un guichet
    def self.edit

    end

    #Historique de chaque guichet
    def self.historique

    end
  end
end