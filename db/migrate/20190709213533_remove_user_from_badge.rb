class RemoveUserFromBadge < ActiveRecord::Migration[5.2]
  def change
    remove_column :badges, :user, :string
  end
end
