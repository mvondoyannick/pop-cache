class AddTwofaToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :two_fa, :string
  end
end
