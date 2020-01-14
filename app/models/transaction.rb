class Transaction < ApplicationRecord

  belongs_to :customer

  before_save :set_color

  validates :code, presence: true, uniqueness: {message: "%{value} est deja utilisé"}


  private
  def set_color
    self.color = "#1976d2" if self.flag == "PAIEMENT"     #rouge
    self.color = "#388e3c" if self.flag == "ENCAISSEMENT" #vert
    self.color = "#e53935" if self.flag == "RETRAIT"      #rouge
    self.color = "#fbc02d" if self.flag == "RECHARGE"     #jaune
    self.color = "#ab47bc" if self.flag == "ABONNEMENT"   #violet
  end
end
