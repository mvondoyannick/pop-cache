class Transactions
  def initialize(marchand, customer, amount, context, flag)
    @marchand = marchand
    @customer = customer
    @amount = amount
    @context = context
    @flag = flag
  end

  #permet de creer une transaction
  def self.transaction

  end

  def self.check(customer)
    @customer = customer
    query = Customer.find_by_authentication_token(customer)
    return true
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: "failed",
      message: "Impossible de trouver cet utilisateur"
    }
  end

  def self.debit
  end

  def self.create
  end

  def self.register
  end
    
end