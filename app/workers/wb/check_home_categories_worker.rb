module Wb
  class CheckHomeCategoriesWorker
    include Sidekiq::Worker

    def perform
      Keyword.pluck(:name).each do |name|
        ::Wb::CheckDiscountsWorker.perform_async(name, [1], 50)
      end
    end
  end
end
