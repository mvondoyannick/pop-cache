# MODEL DE L'UTILISATEUR PRINCIPAL
class Customer < ApplicationRecord
  acts_as_token_authenticatable #pour generer le authentication_token
  belongs_to :type # le type d'un customer, customer | demo
  has_one :badge # Classification d'un customer en fonction de ses activités
  has_one :customer_datum, dependent: :destroy # Les informations du client
  has_one :account, dependent: :destroy # Le compte du client, qui sera supprimé si le client est supprimé
  has_one :history, dependent: :destroy # L'historique du client
  has_one :await, dependent: :destroy # L'intention de retrait du customer
  has_one :answer, dependent: :destroy # Supprime les reponses aux question si le customer est supprimé
  has_one :abonnement, dependent: :destroy # supprimer les abonnements si le customer est supprimé
  has_many :so, dependent: :delete_all # has many SOS account
  has_one :fc_account, dependent: :delete #has one Flash Cash account for this user
  has_many :fc_coupons, dependent: :delete_all # customer has many coupon

  before_create :lock_init

  after_save :generate_apikey
  before_save :generate_code
  before_save :set_hand
  before_save :setName
  before_save :set_cni

  # Create CustomerDatum after new Customer creation
  after_create :set_customer_datum
  #after_create :add_abonnement

  # before_delete customer account
  #before_destroy :verify_amount_before_destroy if 


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  #active storage, gestion de la CNI | Formulaire | des Photos
  has_one_attached :cni_file
  has_one_attached :formulaire
  has_one_attached :photo


  qrcodeable print_path: "app/assets/images/qrcode", identifier: :hand

  VALID_NAME_REGEX = /\A[a-zA-Z\d\-]+\z/i # letters, numbers, dashes
  VALID_SECOND_NAME_REGEX = /\A[^0-9`!@#\$%\^&*+_=]+\z/
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  #validations
  validates :phone, presence: {message: "est obligatoire"}, uniqueness: {message: "%{value} existe deja"}, length: {is: 9, message: "doit avoir 9 chiffres"}, numericality: {only_integer: true}
  # validates :cni, presence: {allow_blank: true, not_allowed: "!@#%*()_-+="}, numericality: {only_integer: true, message: "invalide, uniquement des chiffres"}
  #validates :second_name, presence: {allow_blank: true}, format: {with: VALID_SECOND_NAME_REGEX}, unless: Proc.new { |a| a.second_name.present? }
  validates :name, presence: true, length: { minimum: 3 }
  validates :email, presence: {message: "obligatoire"}, uniqueness: {message: "%{value} existe deja."}
  #validates :password, presence: true, length: {minimum: 6, message: "minimum 6 caracteres"}

  #permet de generer le code/ MIN si et seulement s'il n'existe pas
  def generate_code
    totp = ROTP::TOTP.new("s3cr3tk3y", issuer: self.phone)
    self.code = totp.now
  end

  # Experiment
  def complete_name
    self.name + " " + self.second_name
  end

  #get de path of customer qrcode
  def path_my_qrcode
    #require 'ActionDispatch'
    file = File.join(Rails.root.join, "app", "assets", "images", "#{self.phone}.svg")
    # puts "#{request.host}file" request.host | request.domaine | request.base_url
    # read de file
    if File.exists?(file)
      return file
    else
      return false, "Fichier inexistant"
      puts false
    end
  end

  #print customer qrcode to assets images folder
  def print_my_qrcode
    require 'rqrcode'

    qrcode = RQRCode::QRCode.new("http://api.paiemequick.com/u/p/#{self.authentication_token}/")

    # NOTE: showing with default options specified explicitly
    svg = qrcode.as_svg(
        offset: 5,
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 6,
        standalone: true
    )

    # save SVG file to folder
    File.open("app/assets/images/#{self.phone}", "w") do |line|
      line.puts svg
    end
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
     }.to_s)
  end

  def lock_init
    self.two_fa = false
    self.type_id = 1 # Simple customer
  end

  def set_cni
    self.cni.nil? ? self.cni = false : self.cni
  end

  # TODO VALIDATE CHECKPHONE
  def chechPhone
    # Permet de verifier si le numero de teléphone appartien au cameroun
    phone = Parametre::PersonalData::numeroOperateurMobile(self.phone)
    ActiveRecord::Rollback "Numéro de telephone incorrecte" if phone == "inconnu"
  end

  #Mettre le nom de la personne en majuscule et le code
  # TODO mesearing importance of unless intead of if
  def setName
    self.name.nil? ? "invalid" : self.name.upcase
    self.second_name.nil? ? "" : self.second_name.titleize
      # self.name = self.name.upcase if not self.name.nil?
      # self.second_name = self.second_name.titleize if  not self.second_name.nil?
  end


  #generate hand from email
  def set_hand
    # La forme la plus avancée de génération du QR code
    # "#{self.authentication_token}@amount@lat@long@context"
    hand = "#{self.authentication_token}@0000@0.0@0.0@plateform@#{Time.now}"
    self.hand = Base64.strict_encode64(hand) #.delete("\n")
  end

  # Set customerDatum after new customer registration
  def set_customer_datum
    customer_data = CustomerDatum.new(customer_id: self.id, phone: self.phone)
    #raise ActiveRecord::Rollback if customer_data.save = false
    # if !customer_data.save
    #   raise ActiveRecord::Rollback "Impossible de mettre les données a jour!"
    # end
  end

  # Verifier q'un compte est vide avant de le supprimer
  def verify_amount_before_destroy
    if Account.exists?(customer_id: self.id)
      amount = Account.find_by_customer_id(self.id).amount
      if amount > 0
        puts "Impossible de supprimer le compte de cet utilisateur, son compte n'est pas vide"
        # send SMS to user
        Sms.nexah(self.phone, "#{self.complete_name}, votre compte n'est pas vide! Merci de transferer les fonds vers Orange/MTN/Compte bancaire avant de supprimer votre compte")

        # wait job for 3 seconds
        sleep(3)

        raise ActiveRecord::Rollback
      else
        #delete customer account
        suppression = self.account.destroy!
        if suppression
          puts "Compte supprimé avec succes!"
        else
          puts "Impossible de supprimer ce compte : #{suppression.error.messages}"
        end
      end
    else
      puts "Cet utilisateur ne dispose pas de compte financier."
      # raise ActiveRecord::Rollback
      supp = Customer.find(self.id).destroy!
      puts supp
    end
  end
end
