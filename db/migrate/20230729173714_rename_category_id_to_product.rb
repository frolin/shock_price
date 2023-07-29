class RenameCategoryIdToProduct < ActiveRecord::Migration[7.0]
  def change
    rename_column :products, :category_id, :subject_id
  end
end
