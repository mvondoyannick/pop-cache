class CreateAbonnements < ActiveRecord::Migration[5.2]
  def change
    create_table :abonnements do |t|
      t.references :palier, foreign_key: true
      t.references :customer, foreign_key: true
      t.date :date_debut
      t.date :date_fin

      t.timestamps
    end
  end
end
