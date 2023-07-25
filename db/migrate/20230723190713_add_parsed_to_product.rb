class AddParsedToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :parsed, :boolean, default: false, index: true
  end
end
