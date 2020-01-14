class FcAccount < ApplicationRecord
  belongs_to :customer
  has_many :fc_coupon
end
