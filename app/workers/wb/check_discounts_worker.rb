module Wb
  class CheckDiscountsWorker
    include Sidekiq::Worker

    sidekiq_options queue: :check_discounts, retry: 3

    def perform(query, tag, pages=nil, notify_price=nil)
      ::Wb::DiscountsCheck.run!(query: query, pages: pages, tag: tag, notify_price: notify_price)
    end
  end
end
