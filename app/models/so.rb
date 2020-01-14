class So < ApplicationRecord
  belongs_to :customer
  has_many :sospayment
end
