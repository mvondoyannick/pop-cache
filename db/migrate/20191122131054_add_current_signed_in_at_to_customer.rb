class AddCurrentSignedInAtToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :current_sign_in_at, :datetime
  end
end
