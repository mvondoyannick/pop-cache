class CreatePaliers < ActiveRecord::Migration[5.2]
  def change
    create_table :paliers do |t|
      t.string :amount
      t.string :max_retrait

      t.timestamps
    end
  end
end
