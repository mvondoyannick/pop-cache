class CreateCustomerData < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_data do |t|
      t.references :customer, foreign_key: true
      t.string :phone
      t.string :sim_phone
      t.string :network_operator
      t.string :uuid
      t.string :imei

      t.timestamps
    end
  end
end
