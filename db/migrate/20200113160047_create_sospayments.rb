class CreateSospayments < ActiveRecord::Migration[6.0]
  def change
    create_table :sospayments do |t|
      t.float :amount
      t.integer :payer
      t.datetime :payment_date
      t.boolean :pret
      t.references :so, null: false, foreign_key: true

      t.timestamps
    end
  end
end
