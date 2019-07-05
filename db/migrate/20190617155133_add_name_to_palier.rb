class AddNameToPalier < ActiveRecord::Migration[5.2]
  def change
    add_column :paliers, :name, :string
  end
end
