module Agents
  class Auth

    def self.signup
    end

    def self.signin(phone, password)
      @phone      = phone
      @password   = password 

      #launch query
      agent = Customer.find_by_phone(phone)
      if agent.valid_password?(password)
        return true, agent.as_json(only: [:name, :second_name, :authentication_token, :phone])
      else
        return false, "Utilisateur inconnu"
      end
    end

    def self.lock
    end

    #permet de retrouver son mot de passe
    def self.password
    end
  end

  class Search
  end
end