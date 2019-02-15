class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #validations
  validates :phone, uniqueness: {message: "%{value} a deja ete utilisé" }, length: { is: 9, message: "Le numéro doit avoir 9 chiffres" }
  validates :cni, presence: {message: "%{value} a deja ete utilisé" } #, length: {in: 12..20}
  validates :name, length: { in: 3..50 }#, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }
  #validates :phone, presence: {message: "Ne peut etre vide"} #length: { is: 8, message: "Le numéro doit avoir 9 chiffres" }
  validates :password, confirmation: {message: "Les motes de passes semblent etre different"}
end
