class Account < ApplicationRecord
  belongs_to :customer

  before_save :sign_amount #, on: [:create, :update]

  # action apres la creation du compte
  after_create :add_abonnement


  #validation
  #validates_presence_of :name, presence: true
  #
  private

  # Permet de signer le montant pour le rendre illisible
  def sign_amount
    #final_amount = JWT.encode self.amount, Rails.application.secrets.secret_key_base, 'none'
    #self.amount = final_amount
  end

  # Ajouter un abonnement apres la creation du compte client
  def add_abonnement
    Abonnements::Abonnements.add(1, Account.find(self.id).customer.id)
  end
end
