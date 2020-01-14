class Qrmodel < ApplicationRecord
  belongs_to :service
  has_one_attached :qrcode
end
