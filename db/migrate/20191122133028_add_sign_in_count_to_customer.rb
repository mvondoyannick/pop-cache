class AddSignInCountToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :sign_in_count, :integer
  end
end
