class AddCamountToSo < ActiveRecord::Migration[6.0]
  def change
    add_column :sos, :camount, :float
    add_column :sos, :paycomplete, :boolean
  end
end
