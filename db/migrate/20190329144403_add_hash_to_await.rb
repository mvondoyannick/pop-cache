class AddHashToAwait < ActiveRecord::Migration[5.2]
  def change
    add_column :awaits, :hash, :string
    add_column :awaits, :end, :string
    add_column :awaits, :used, :boolean
  end
end
