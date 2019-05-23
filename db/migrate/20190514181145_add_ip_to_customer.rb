class AddIpToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :ip, :string
    add_column :customers, :pays, :string
  end
end
