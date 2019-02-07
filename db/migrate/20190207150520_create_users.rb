class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :second_name
      t.string :phone
      t.string :cni
      t.string :ville
      t.string :password

      t.timestamps
    end
  end
end
