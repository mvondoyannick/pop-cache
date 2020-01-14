class CreateDemoUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :demo_users do |t|
      t.string :phone
      t.string :date_debut
      t.string :date_fin
      t.integer :request_day
      t.integer :request_mount
      t.string :status

      t.timestamps
    end
  end
end
