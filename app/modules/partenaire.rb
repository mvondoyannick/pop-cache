module Partenaire

  class Authenticate

    def initialize(arg)
      $email      = arg[:email]
      $password   = arg[:password]

    end

    #Authentification sur la plateforme
    def self.signin
      puts $email

      #on recherche a identifier le partenaire
      agent = Agent.find_by_email($email)
      if agent.blank?
        return false, "Utilisateur inconnu"
      else
        if agent.valid_password?($password)
          return true, agent.as_json(only: [:name, :prenom, :phone, :authentication_token])
        else
          return false, "Email ou mot de passe invalide"
        end
      end

    end

    #Creation de compte sur la plateforme
    def self.signup

    end

    #Bloquer un agent
    def self.lock

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