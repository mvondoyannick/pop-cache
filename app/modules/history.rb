class History
    def initialize
        
    end

    def self.get_user_history(phone)
        @phone = phone
        history = Transaction.where(client_phone: @phone).order(created_at: :desc)
        if history
            return history.as_json(only: [:client_phone, :client_name, :amount, :created_at])
        end
    end


    #permet de faire l'historique des depots
    def self.depot
    end

    def self.retrait
    end

    def self.payment
    end

    def self.encaisser
    end
end