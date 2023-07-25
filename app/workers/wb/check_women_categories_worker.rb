module Wb
  class CheckWomenCategoriesWorker
    include Sidekiq::Worker

    def perform
      Category.women.each do |category|
        ::Wb::CheckDiscountsWorker.perform_async(category)
      end
    end
  end
end
