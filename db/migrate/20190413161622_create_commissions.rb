class CreateCommissions < ActiveRecord::Migration[5.2]
  def change
    create_table :commissions do |t|
      t.string :code
      t.string :amount_brut
      t.string :amount_commission
      t.string :commission

      t.timestamps
    end
  end
end
