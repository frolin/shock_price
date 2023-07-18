module Wb
  class CheckCategoryWorker
    include Sidekiq::Worker

    sidekiq_options queue: :check_discounts, retry: 3

    def perform(category_id)
      category = Category.find(category_id)
      ::Wb::MassSearchByQuery.run(category: category)
    end
  end
end
