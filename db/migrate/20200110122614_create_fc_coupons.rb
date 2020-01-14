class CreateFcCoupons < ActiveRecord::Migration[6.0]
  def change
    create_table :fc_coupons do |t|
      t.float :amount
      t.integer :coupon_code
      t.string :receiver_phone
      t.string :receiver_name
      t.integer :auth_coupon_code
      t.references :fc_account, null: false, foreign_key: true
      t.boolean :coupon_paid
      t.datetime :coupon_date_paid
      t.string :agence_id
      t.string :lat
      t.string :lon
      t.string :coupon_confirmation_code

      t.timestamps
    end
  end
end
