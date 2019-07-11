class RemoveImeiFromCustomerDatum < ActiveRecord::Migration[5.2]
  def change
    remove_column :customer_data, :imei, :string
    remove_column :customer_data, :latitude, :string
    remove_column :customer_data, :longitude, :string
    remove_column :customer_data, :network_operator, :string
    remove_column :customer_data, :sim_phone, :string
  end
end
