module CustomerClient
  class PayWithCode

    def self.pay
      return nil
    end
    
  end



  class Client
    def self.get_customer(phone)
      @phone = phone

      query = Customer.where(phone: @phone).first
      return query
    end
  end

end