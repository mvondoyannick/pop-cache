class RemoveAwaitFromCustomer < ActiveRecord::Migration[5.2]
  def change
    remove_column :customers, :await, :string
  end
end
