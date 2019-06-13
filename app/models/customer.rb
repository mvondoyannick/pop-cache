class Customer < ApplicationRecord
  acts_as_token_authenticatable     #pour generer le authentication_token
  belongs_to :type
  has_one :badge
  has_one :customer_datum
  has_one :account

  before_save :generate_apikey
  before_save :set_hand
  before_save :setName
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #active storage
  has_one_attached :cni_file
  has_one_attached :formulaire
  has_one_attached :photo


  qrcodeable print_path: "app/assets/images/qrcode", identifier: :hand


  #validations
  validates :phone,presence:true, uniqueness: {message: "%{value} a deja ete utilisé" }, length: { is: 9, message: "Le numéro doit avoir 9 chiffres" }
  #validates :cni, presence: {message: "%{value} a deja ete utilisé" } #, length: {in: 12..20}
  validates :name, presence: true #length: { in: 3..50 }#, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }
  #validates :cni, presence: true, uniqueness: {message: "%{value} a deja ete utilisé"}
  validates :email, presence: true, uniqueness: {message: "%{value} a deja ete utilisé."}

  #permet de generer le code si et seulement s'il n'existe pas
  def generate_code
    if self.code.nil?
      self.code = rand(5**5)
    end
  end

  private
  def generate_apikey
    self.apikey = Base64.encode64({
      id: self.authentication_token,
      montant: nil,
      long: nil,
      lat: nil,
      context: "plateform",
      date: nil
    }.to_s).delete("\n")
  end

  #Mettre le nom de la personne en majuscule et le code
  def setName
    self.name         = self.name.upcase
    self.second_name  = self.second_name.capitalize
    self.code = rand(11**11)
  end


  #generate hand from email
  def set_hand
    hand = "#{self.authentication_token}@null@null@null@plateform@null"
    self.hand = Base64.encode64(hand).delete("\n")
    #Base64.encode64(self.email).delete("\n")
  end


end
