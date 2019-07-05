class Palier < ApplicationRecord

  has_one :abonnement

  validates :name, presence: true, uniqueness: {message: "%{value} a deja été utilisé"}
  validates :amount, presence: true, uniqueness: {message: "%{value} a deja été utilisé comme montant"}
  validates :max_retrait, presence: true, uniqueness: {message: "%{value} a deja utilisé comme retrait maximum"}
end
