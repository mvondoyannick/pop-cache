class AddContextToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :context, :string
  end
end
