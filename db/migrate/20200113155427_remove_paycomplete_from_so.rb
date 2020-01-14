class RemovePaycompleteFromSo < ActiveRecord::Migration[6.0]
  def change

    remove_column :sos, :paycomplete, :boolean

    remove_column :sos, :camount, :float

    remove_column :sos, :pret, :boolean

    remove_column :sos, :payment_date, :string

    remove_column :sos, :receiver, :integer
  end
end
