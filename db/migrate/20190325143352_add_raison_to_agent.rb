class AddRaisonToAgent < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :raison, :string
    add_column :agents, :password, :string
  end
end
