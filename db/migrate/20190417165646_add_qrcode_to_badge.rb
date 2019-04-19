class AddQrcodeToBadge < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :qrcode, :string
  end
end
