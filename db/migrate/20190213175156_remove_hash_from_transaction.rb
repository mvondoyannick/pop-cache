class RemoveHashFromTransaction < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :hash, :string
  end
end
