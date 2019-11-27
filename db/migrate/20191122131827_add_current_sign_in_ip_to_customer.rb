class AddCurrentSignInIpToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :current_sign_in_ip, :string
  end
end
