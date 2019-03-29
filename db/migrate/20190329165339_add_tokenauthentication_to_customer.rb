class AddTokenauthenticationToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :tokenauthentication, :string
  end
end
