class AddPrenomToAgent < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :prenom, :string
    add_column :agents, :phone, :string
  end
end
