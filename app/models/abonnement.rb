class Abonnement < ApplicationRecord
  belongs_to :palier
  belongs_to :customer

  validates :customer_id, presence: true, uniqueness: {message: "%{value} a deja un abonnement en cours"}

end
