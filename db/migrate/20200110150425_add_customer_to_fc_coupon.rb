class AddCustomerToFcCoupon < ActiveRecord::Migration[6.0]
  def change
    add_reference :fc_coupons, :customer, null: true, foreign_key: true
  end
end
