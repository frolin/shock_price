module Wb
  class QuerySearchWorker
    include Sidekiq::Worker

    sidekiq_options queue: :discounts_import

    def perform

      Wb::QuerySearch.run!(query: '')
    end
  end
end
