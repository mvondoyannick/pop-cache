class AddSexeToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :sexe, :string
  end
end
