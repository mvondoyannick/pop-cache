class AddKeyToService < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :key, :string
  end
end
