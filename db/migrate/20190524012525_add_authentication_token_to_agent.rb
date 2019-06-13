class AddAuthenticationTokenToAgent < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :authentication_token, :string, limit: 30
    add_index :agents, :authentication_token, unique: true
  end
end
