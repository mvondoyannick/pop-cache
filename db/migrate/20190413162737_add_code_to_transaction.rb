class AddCodeToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :code, :string
  end
end
