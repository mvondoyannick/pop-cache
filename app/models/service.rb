class Service < ApplicationRecord
  belongs_to :cat
  before_save :generate_key
  validates :name, presence: true

  private
  def generate_key
    self.key = Parametre::Crypto::cryptoSSL(self.name.upcase) if self.key.nil?
  end
end
