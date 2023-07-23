class AddWebapiDataToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :webapi_data, :jsonb, default: {}
  end
end
