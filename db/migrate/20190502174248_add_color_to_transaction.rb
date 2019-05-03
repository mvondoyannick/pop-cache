class AddColorToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :color, :string
  end
end
