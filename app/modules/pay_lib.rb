# PERMET DE FOURNIR LES PAIEMENTS DE SOLUTIONS QUE L'UTILISATEUR POURRAIT UTILISER
# EN PLUS DE PAYER AVEC SON COMPTE PAYMEQUICK
# TODO FINALIZE THIS MODULE
module PayLib

  # MANAGE PAYMENT SOLUTION FOR PLATEFORM API
  class PaymentSolution

    # ADD PAYMENT SOLUTION
    def self.add

    end


    # UPDATE PAYMENT SOLUTION
    def self.update

    end


    # LOCK PAYMENT SOLUTION
    def self.lock

    end

    # DELETE PAYMENT SOLUTION
    def self.delete(id)


    end

    # LIST ALL PAYMENT SOLUTIONS AVAILABLE
    def self.list

    end
  end

  class CustomerPaymentSolution

    # LISTE CUSTOMER PAYMENT SOLUTION
    # @param [Integer] customer_id
    # @return [Object] list
    def self.list(token)
      @token = token

    end

    # CONFIGURE AND ADD A PAYMENT SOLUTION TO CUSTOMER ACCOUNT
    # @param [Object] customer_id
    # @param [Object] payment_solution_id
    def self.add(argv)
      @token = argv[:token]
      @payment_solution_id = argv[:payment_solution_id]
    end


    # BLOQUER UNE SOLUTION DE PAIEMENT PAR UN UTILISATEUR
    def self.lock(args)
      @token = args[:token]
      @payment_solution_id = args[:payment_solution_id]

    end


    # DELETE PAYMENT SOLUTION LINKED TO CUSTOMER ACCOUNT
    def self.delete(argv)
      @token = argv[:token]
      @payment_solution_id = argv[:payment_solution_id]
    end
  end
end