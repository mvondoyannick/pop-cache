class CreateBadges < ActiveRecord::Migration[5.2]
  def change
    create_table :badges do |t|
      t.references :customer, foreign_key: true
      t.boolean :activate

      t.timestamps
    end
  end
end
