class AddAwaitToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :await, :string
  end
end
