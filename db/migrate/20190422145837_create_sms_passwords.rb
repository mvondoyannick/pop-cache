class CreateSmsPasswords < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_passwords do |t|
      t.references :customer, foreign_key: true
      t.string :code
      t.string :status

      t.timestamps
    end
  end
end
