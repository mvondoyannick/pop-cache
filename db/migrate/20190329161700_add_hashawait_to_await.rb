class AddHashawaitToAwait < ActiveRecord::Migration[5.2]
  def change
    add_column :awaits, :hashawait, :string
  end
end
