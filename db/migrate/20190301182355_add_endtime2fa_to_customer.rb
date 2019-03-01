class AddEndtime2faToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :perime_two_fa, :string
  end
end
