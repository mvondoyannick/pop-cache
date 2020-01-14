class SetAccount

    def initialize(user_id)
      @user_id = user_id
    end

    def self.credit
    end

    #permet de creer un compte apres creation d'un compte et initialisation de ce compte a nil
    def self.account(id)
      init_account = 0
      user_id = 1

      query = Account.new(id)
      if query.save
        return 'succes'
      else
        return 'failed'
      end
    end

    def self.debit
    end
end