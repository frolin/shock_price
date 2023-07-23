class AddCatIdToCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :cat_id, :string
  end
end
