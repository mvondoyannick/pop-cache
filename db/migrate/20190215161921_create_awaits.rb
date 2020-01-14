class CreateAwaits < ActiveRecord::Migration[5.2]
  def change
    create_table :awaits do |t|
      t.string :amount
      t.references :customer, foreign_key: true

      t.timestamps
    end
  end
end
