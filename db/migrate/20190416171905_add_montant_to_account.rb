class AddMontantToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :amount, :float
  end
end
