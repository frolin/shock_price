module Wb
  class CheckDiscountsWorker
    include Sidekiq::Worker

    sidekiq_options queue: :check_discounts, retry: 3

    def perform(query, pages=nil)
      ::Wb::DiscountsCheck.run!(query: query, pages: pages)
    end
  end
end
