module Wb
  class CheckGadgetCategoriesWorker
    include Sidekiq::Worker

    def perform
      Category.gadgets.find_each do |category|
        ::Wb::CheckDiscountsWorker.perform_async(category.name, 'гаджеты', [1,2,3,4,5], 30)
      end

    end
  end
end
