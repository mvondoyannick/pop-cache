class RemoveUserFromAccount < ActiveRecord::Migration[5.2]
  def change
    #remove_reference :accounts, :user, foreign_key: true
  end
end
