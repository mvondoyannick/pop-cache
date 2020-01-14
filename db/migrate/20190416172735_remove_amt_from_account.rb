class RemoveAmtFromAccount < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :amt, :float
  end
end
