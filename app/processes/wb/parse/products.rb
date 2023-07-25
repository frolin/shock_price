module Wb
  module Parse
    class Products < ActiveInteraction::Base
      record :product

      def execute

        product.transaction do
          product.update!(data: product_data)

          product.update!(parsed: true)
          Rails.logger.debug("#{product.sku} parsed")
        end
      end

      private

      def product_data
        @product_data ||= Wb::ProductParse.run!(sku: product.sku)
      end
    end
  end
end