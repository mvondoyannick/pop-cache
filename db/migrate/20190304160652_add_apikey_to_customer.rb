class AddApikeyToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :apikey, :string
  end
end
