class AddKeyToDemoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :demo_users, :key, :string
  end
end
