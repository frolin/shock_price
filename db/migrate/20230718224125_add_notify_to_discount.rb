class AddNotifyToDiscount < ActiveRecord::Migration[7.0]
  def change
    add_column :discounts, :notify, :boolean, default: false
  end
end
