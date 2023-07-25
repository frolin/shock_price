module Wb
  class ProductsParserWorker
    include Sidekiq::Worker

    sidekiq_options queue: :product_parsing

    def perform
      Product.where(parsed: false).find_each do |product|
        ::Wb::ParseProductWorker.perform_async(product.sku)
      end
    end
  end
end
