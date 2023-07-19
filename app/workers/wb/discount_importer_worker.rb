module Wb
  class DiscountImporterWorker
    include Sidekiq::Worker

    sidekiq_options queue: :discounts_import

    def perform(products_data_json)
      products_data = JSON.parse(products_data_json)

      Wb::Discounts::Importer.run!(products_data: products_data)
    end
  end
end
