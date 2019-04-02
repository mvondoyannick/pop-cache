class Customer < ApplicationRecord
  before_save :generate_apikey
  before_save :set_hand
  after_save :generate_qr
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #active storage
  has_one_attached :picture_cni
  has_one_attached :formulaire
  has_one_attached :avatar


  qrcodeable print_path: "app/assets/images/qrcode", identifier: :hand


  #validations
  validates :phone, uniqueness: {message: "%{value} a deja ete utilisé" }, length: { is: 9, message: "Le numéro doit avoir 9 chiffres" }
  #validates :cni, presence: {message: "%{value} a deja ete utilisé" } #, length: {in: 12..20}
  validates :name, presence: true #length: { in: 3..50 }#, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }
  validates :phone, presence: {message: "Ne peut etre vide"} #length: { is: 8, message: "Le numéro doit avoir 9 chiffres" }
  #validates :password, presence: true

  private
  def generate_apikey
    self.apikey = Base64.encode64({
      id: self.id,
      montant: nil,
      long: nil,
      lat: nil,
      context: "plateform",
      date: nil
    }.to_s).delete("\n")
  end


  #generate hand from email
  def set_hand
    self.hand = "#{self.id}@null@null@null@plateform@null"
    #Base64.encode64(self.email).delete("\n")
  end

  def generate_qr

  end

end
