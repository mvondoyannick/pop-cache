class Customer < ApplicationRecord
  acts_as_token_authenticatable     #pour generer le authentication_token
  belongs_to :type
  has_one :badge
  has_one :customer_datum
  has_one :account
  has_one :history

  before_save :generate_apikey
  before_save :set_hand
  before_save :setName
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

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

  def bjr
    require 'aes'
    key = Rails.application.secrets.secret_key_base #AES.key
    # puts "bonjour current model"
    qrtoken = {
      id: self.authentication_token,
      date: Time.now
    }
    # creating normalize qrcode
    puts AES.encrypt(qrtoken.to_s, key)
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

  # TODO VALIDATE CHECKPHONE
  def chechPhone
    # Permet de verifier si le numero de teléphone appartien au cameroun
    if self.phone.length == 9
      if self.phone.slide(0) != "6"

        raise ActiveRecord::Rollback

      elsif self.phone.slice(0) != "3"

        raise ActiveRecord::Rollback

      elsif  self.phone.slice(0) != "2"

        raise ActiveRecord::Rollback

      end
    end

  end

  #Mettre le nom de la personne en majuscule et le code
  def setName
    self.name         = self.name.upcase
    self.second_name  = self.second_name.capitalize
    self.code = rand(11**11)
  end


  #generate hand from email
  def set_hand
    # La forme la plus avancée de génération du QR code
    # "#{self.authentication_token}@amount@lat@long@context"
    hand = "#{self.authentication_token}@0000@0.0@0.0@plateform@#{Time.now}"
    self.hand = Base64.encode64(hand).delete("\n")
  end


end
