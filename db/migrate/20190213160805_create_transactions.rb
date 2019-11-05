class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.string :date
      t.string :client_phone
      t.string :client_name
      t.string :marchand_phone
      t.string :marchand_name
      t.string :amount
      t.string :hash
      #t.string :date

      t.timestamps
    end
  end
end
