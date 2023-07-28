module Wb
  class CheckDiscountsWorker
    include Sidekiq::Worker

    sidekiq_options queue: :check_discounts, retry: 3

    def perform(category_name, pages=nil)
      ::Wb::DiscountsCheck.run!(query: category_name, pages: pages)
    end
  end
end
