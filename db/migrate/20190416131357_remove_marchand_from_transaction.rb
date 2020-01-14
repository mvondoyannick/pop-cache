class RemoveMarchandFromTransaction < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :marchand, :string
  end
end
