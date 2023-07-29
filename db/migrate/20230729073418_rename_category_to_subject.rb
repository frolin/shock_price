class RenameCategoryToSubject < ActiveRecord::Migration[7.0]
  def change
    rename_table :categories, :subjects
  end
end
