module Wb
  class CheckHomeCategoriesWorker
    include Sidekiq::Worker

    def perform
      Keyword.pluck(:name).each do |name|
        ::Wb::CheckDiscountsWorker.perform_async(name, [1], 50)
      end

       ::Wb::CheckDiscountsWorker.perform_async('Кухня', [1,2,3,4,5], 50)
    end
  end
end
