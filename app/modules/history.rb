class History
    def initialize
        
    end

    def self.get_user_history(phone)
        @phone = phone
        history = Transaction.where(client_phone: @phone)
        if history
            return history.as_json(only: [:client_phone, :client_name, :amount, :created_at])
        end
    end
end