class AddPwdChangedToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :pwd_changed, :boolean
  end
end
