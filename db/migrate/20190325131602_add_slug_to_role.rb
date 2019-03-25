class AddSlugToRole < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :slug, :string
  end
end
