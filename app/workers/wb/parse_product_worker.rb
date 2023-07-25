module Wb
  class ParseProductWorker
    include Sidekiq::Worker

    sidekiq_options queue: :product_parsing

    def perform(sku)
      product = Product.find_by!(sku: sku)

      ::Wb::Parse::Products.run!(product: product)
    end
  end
end
