class AddActiveToSubject < ActiveRecord::Migration[7.0]
  def change
    add_column :subjects, :active, :boolean, index: true
  end
end
