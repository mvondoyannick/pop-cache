class CreateQrmodels < ActiveRecord::Migration[5.2]
  def change
    create_table :qrmodels do |t|
      t.string :context
      t.string :montant
      t.string :lat
      t.string :lon
      t.string :depart
      t.string :arrive
      t.references :service, foreign_key: true

      t.timestamps
    end
  end
end
