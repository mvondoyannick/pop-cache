class Logger
    def self.formatLogger(tate, c_phone, c_name, m_name, m_phone, amount, context)
      container = {
        date: Time.now,
        client_phone: "691451189",
        client_name: "MVONDO",
        marchant_phone: "000000000",
        marchant_name: "FYLO",
        amount: "2500",
        context: "phone",
        flag: ""
      }
    end

    #permet d'enregistre l'historique d'une transaction
    def self.register(date, c_phone, c_name, m_name, m_phone, amount, context, flag)
      @date = date
      @customer_phone = c_phone
      @customer_name = c_name
      @merchant_phone = m_phone
      @merchant_name = m_name
      @transaction_amount = amount

    end

end
