class CreateFcAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :fc_accounts do |t|
      t.integer :account_code
      t.float :amount
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
