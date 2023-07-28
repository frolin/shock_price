module Wb
  class CheckWomenCategoriesWorker
    include Sidekiq::Worker

    def perform
       Category.women.each do |category_name|
        ::Wb::CheckDiscountsWorker.perform_async(category_name, pages: [1,2,3])
      end
    end
  end
end
