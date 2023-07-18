module Wb
  class CheckAllCategoriesWorker
    include Sidekiq::Worker

    def perform
      Category.with_subcategories.each do |category|
        CheckCategoryWorker.perform_async(category.id)
      end

      # CheckCategoryWorker.perform_async(Category.with_subcategories.first.id)
    end
  end
end
