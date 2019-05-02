class Transaction < ApplicationRecord
  before_save :set_color


  private
  def set_color
    self.color = "#FFF" if self.flag == "PAIEMENT"
    self.color = "#000" if self.flag == "ENCAISSEMENT"
  end
end
