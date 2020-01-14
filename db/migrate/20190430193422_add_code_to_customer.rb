class AddCodeToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :code, :string
  end
end
