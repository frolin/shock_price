class CreateDiscounts < ActiveRecord::Migration[7.0]
  def change
    create_table :discounts do |t|
      t.references :product, null: false, foreign_key: true
      t.references :price, null: false, foreign_key: true
      t.jsonb :data, default: {}

      t.timestamps
    end
  end
end
