class AddDeviceToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :device, :string
  end
end
