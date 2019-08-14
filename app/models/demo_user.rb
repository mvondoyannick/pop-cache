class DemoUser < ApplicationRecord
  require 'aes'
  has_one :demo_user_account
  validates :phone, uniqueness: {message: "%{value} est deja utilisé"}, length: {is: 9, message: "Le numéro doit avoir 9 chiffres"}

end
