class AddDeviceToCustomerDatum < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_data, :device, :string
  end
end
