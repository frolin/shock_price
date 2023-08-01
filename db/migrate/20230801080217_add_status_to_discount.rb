class AddStatusToDiscount < ActiveRecord::Migration[7.0]
  def change
    add_column :discounts, :status, :integer, default: 0
  end
end
