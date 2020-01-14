class AddCatToService < ActiveRecord::Migration[5.2]
  def change
    add_reference :services, :cat, foreign_key: true
  end
end
