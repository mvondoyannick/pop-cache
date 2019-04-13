class RemoveClientPhoneFromTransaction < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :client_phone, :string
    remove_column :transactions, :client_name, :string
    remove_column :transactions, :marchand_phone, :string
    remove_column :transactions, :marchand_name, :string
  end
end
