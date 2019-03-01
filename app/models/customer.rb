class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #active storage
  has_one_attached :picture_cni
  has_one_attached :formulaire
  has_one_attached :avatar
  #validations
  validates :phone, uniqueness: {message: "%{value} a deja ete utilisé" }, length: { is: 9, message: "Le numéro doit avoir 9 chiffres" }
  #validates :cni, presence: {message: "%{value} a deja ete utilisé" } #, length: {in: 12..20}
  validates :name, length: { in: 3..50 }#, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }
  #validates :phone, presence: {message: "Ne peut etre vide"} #length: { is: 8, message: "Le numéro doit avoir 9 chiffres" }
  #validates :password, presence: true
end
