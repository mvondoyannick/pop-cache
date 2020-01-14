class AddNameToAgent < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :name, :string
  end
end
