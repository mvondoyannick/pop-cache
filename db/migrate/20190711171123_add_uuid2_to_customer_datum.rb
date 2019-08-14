class AddUuid2ToCustomerDatum < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_data, :uuid2, :string
  end
end
