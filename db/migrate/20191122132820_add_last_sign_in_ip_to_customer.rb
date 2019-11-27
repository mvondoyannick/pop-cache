class AddLastSignInIpToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :last_sign_in_ip, :string
  end
end
