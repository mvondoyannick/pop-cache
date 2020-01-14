class RemoveAmountFromAccount < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :amount, :integer
  end
end
