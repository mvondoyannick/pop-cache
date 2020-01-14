class AddUserToBadge < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :user, :string
  end
end
