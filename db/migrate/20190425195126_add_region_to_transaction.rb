class AddRegionToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :region, :string
    add_column :transactions, :ip, :string
    add_column :transactions, :lat, :string
    add_column :transactions, :long, :string
  end
end
