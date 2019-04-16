class AddAmtToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :amt, :float
  end
end
