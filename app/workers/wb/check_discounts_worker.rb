module Wb
  class CheckDiscountsWorker
    include Sidekiq::Worker

    sidekiq_options queue: :check_discounts, retry: 3

    def perform(category_name)
      ::Wb::DiscountsCheck.run!(query: category_name, pages: [1,2,3])
    end
  end
end
