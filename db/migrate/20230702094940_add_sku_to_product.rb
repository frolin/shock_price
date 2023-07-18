class AddSkuToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :sku, :string, index: true
  end
end
