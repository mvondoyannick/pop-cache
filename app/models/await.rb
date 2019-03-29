class Await < ApplicationRecord
  before_save :set_hash
  belongs_to :customer

  private
    def set_hash
      self.hashawait = SecureRandom.hex(10) #la clé pour le hash courant
      self.end = 5.minutes.from_now
      self.used = false
    end
end
