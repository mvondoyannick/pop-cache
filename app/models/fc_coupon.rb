class FcCoupon < ApplicationRecord
  belongs_to :fc_account
  belongs_to :customer
end
