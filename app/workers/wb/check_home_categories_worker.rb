module Wb
  class CheckHomeCategoriesWorker
    include Sidekiq::Worker

    def perform
      Keyword.pluck(:name).each do |category_name|
        ::Wb::CheckDiscountsWorker.perform_async(category_name)
      end
    end
  end
end
