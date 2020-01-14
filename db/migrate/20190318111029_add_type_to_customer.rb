class AddTypeToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_reference :customers, :type, foreign_key: true
  end
end
