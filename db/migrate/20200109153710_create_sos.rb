class CreateSos < ActiveRecord::Migration[6.0]
  def change
    create_table :sos do |t|
      t.float :montant
      t.string :delais
      t.string :code
      t.boolean :use
      t.integer :receiver
      t.string :payment_date
      t.boolean :pret
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
