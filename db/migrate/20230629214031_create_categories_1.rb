class CreateCategories1 < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :url
      t.jsonb :data, default: {}

      t.timestamps
    end
  end
end
