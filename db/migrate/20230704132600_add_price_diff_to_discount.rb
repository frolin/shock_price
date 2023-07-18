class AddPriceDiffToDiscount < ActiveRecord::Migration[7.0]
  def change
    add_column :discounts, :price_diff, :integer
    add_column :discounts, :price_percent, :integer
  end
end
