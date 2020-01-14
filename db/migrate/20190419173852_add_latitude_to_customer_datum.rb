class AddLatitudeToCustomerDatum < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_data, :latitude, :string
    add_column :customer_data, :longitude, :string
    add_column :customer_data, :customer_ip, :string
  end
end
