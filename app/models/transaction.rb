class Transaction < ApplicationRecord
  before_save :set_color


  private
  def set_color
    self.color = "#e53935" if self.flag == "PAIEMENT"     #rouge
    self.color = "#283593" if self.flag == "ENCAISSEMENT" #violet
    self.color = "#bf360c" if self.flag == "RETRAIT"      #Orange sombre, degré 900
    self.color = "#000000" if self.flag == "RECHARGE"     #noir
  end
end
