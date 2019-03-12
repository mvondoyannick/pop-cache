module PartnersPlateform
  class Partner

    def initialize(phone, password, rib)
      $phone    = phone
      $password = password
      $rib      = rib    
    end

    def self.partnerAuthenticate
      partner = Partner.where(phone: $phone, rib: $rib).first
      if partner.valid_password?($password)
        puts 'loged in'
      else
        puts 'acces refusé'
      end
    end

  end  
  
  #permet aux partenaire de manipuler les clients de la plateforme
  class Client
    attr_reader :date

    def initialize(phone)
    end

    def self.credit(phone, amount, credential)
    end

    def self.debit(phone, amount, credential)
    end

    def self.create(name, second_name, cni)
    end

    def self.processFinalize(cni)
    end

    def self.recovery
    end

    def self.update(*arg)
    end

  end
end