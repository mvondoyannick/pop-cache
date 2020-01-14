class AddCloseToSo < ActiveRecord::Migration[6.0]
  def change
    add_column :sos, :close, :boolean
  end
end
