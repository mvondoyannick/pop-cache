class AddMarchandToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :marchand, :string
    add_column :transactions, :customer, :string
    add_column :transactions, :flag, :string
  end
end
