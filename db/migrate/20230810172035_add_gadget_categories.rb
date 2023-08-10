class AddGadgetCategories < ActiveRecord::Migration[7.0]
  def change
    ::Category::GADGET_CATEGORY_NAMES.each do |category_name|
      Category.create!(name: category_name)
    end
  end
end
