class RemoveHashFromAwait < ActiveRecord::Migration[5.2]
  def change
    remove_column :awaits, :hash, :string
  end
end
