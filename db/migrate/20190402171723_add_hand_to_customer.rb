class AddHandToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :hand, :string
  end
end
