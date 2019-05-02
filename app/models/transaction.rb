class Transaction < ApplicationRecord
  before_save :set_color


  private
  def set_color
    self.color = "#e53935" if self.flag == "PAIEMENT"
    self.color = "#283593" if self.flag == "ENCAISSEMENT"
  end
end
