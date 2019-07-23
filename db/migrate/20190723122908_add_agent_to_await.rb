class AddAgentToAwait < ActiveRecord::Migration[5.2]
  def change
    add_column :awaits, :agent, :string
  end
end
