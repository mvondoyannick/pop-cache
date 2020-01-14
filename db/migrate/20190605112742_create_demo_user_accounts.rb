class CreateDemoUserAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :demo_user_accounts do |t|
      t.references :demo_user, foreign_key: true
      t.float :amount

      t.timestamps
    end
  end
end
