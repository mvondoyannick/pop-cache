class AddRoleToAgent < ActiveRecord::Migration[5.2]
  def change
    add_reference :agents, :role, foreign_key: true
  end
end
