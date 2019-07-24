class Customer < ApplicationRecord
  acts_as_token_authenticatable     #pour generer le authentication_token
  belongs_to :type          # le type d'un customer, customer | demo
  has_one :badge            # Classification d'un customer en fonction de ses activités
  has_one :customer_datum, dependent: :destroy   # Les informations du client
  has_one :account, dependent: :destroy          # Le compte du client, qui sera supprimé si le client est supprimé
  has_one :history, dependent: :destroy          # L'historique du client
  has_one :await, dependent: :destroy            # L'intention de retrait du customer

  before_save :generate_apikey, on: :create
  before_save :generate_code, on: :create
  before_save :set_hand, on: :create
  before_save :setName, on: :create
  before_save :set_cni, on: :create

  # Create CustomerDatum after new Customer creation
  after_create :set_customer_datum

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  #active storage, gestion de la CNI | Formulaire | des Photos
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

  #permet de generer le code/ MIN si et seulement s'il n'existe pas
  def generate_code
    # if self.code.nil?
    #  self.code = rand(5**5)
    #end
    self. code = rand(5**5) if self.code.nil?
  end

  # Experiment
  def complete_name
    self.name + " " + self.second_name
  end

  private
  def generate_apikey
    self.apikey = Base64.strict_encode64({
      id: self.authentication_token,
      montant: nil,
      long: nil,
      lat: nil,
      context: "plateform",
      date: nil
    }.to_s) #.delete("\n")
  end

  def set_cni
    self.cni = "**vide**" if self.cni.nil?

    sleep 30
    Sms::sender(self.phone, "Pensez a renseigner votre Carte Natinale dans les 30 jours, sinon vous serez suspendu!") if self.cni.nil?
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
  # TODO mesearing importance of unless intead of if
  def setName
    self.name = self.name.upcase if not self.name.nil?
    self.second_name = self.second_name.titleize if  not self.second_name.nil?
    # self.code = rand(5**5)
  end


  #generate hand from email
  def set_hand
    # La forme la plus avancée de génération du QR code
    # "#{self.authentication_token}@amount@lat@long@context"
    hand = "#{self.authentication_token}@0000@0.0@0.0@plateform@#{Time.now}"
    self.hand = Base64.encode64(hand).delete("\n")
  end

  # Set customerDatum after new customer registration
  def set_customer_datum
    customerDatum = CustomerDatum.new(customer_id: self.id, phone: self.phone)
    customerDatum.save
  end


end
