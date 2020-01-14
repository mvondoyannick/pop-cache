class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
      t.references :customer, foreign_key: true
      t.float :amount
      t.string :context
      t.string :flag
      t.string :code
      t.string :region
      t.string :ip
      t.float :lat
      t.float :long
      t.string :color

      t.timestamps
    end
  end
end
