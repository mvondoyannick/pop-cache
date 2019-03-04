module PopJob
  "retourne toutes les jobs de la plateforme"
  
  #verifie toutes les informations/jobs sur le clients
  class ClientJob
    def initialize(phone)
      @attribute = phone
    end

    def self.factor_auth(phone)
    end
  end

  class AgentJob
  end

  class DatabaseJob
  end
end