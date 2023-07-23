module Wb
  class QuerySearch < ActiveInteraction::Base

    string :query
    array :pages, default: nil

    def execute
      price_changed = []

      if pages.present?
        items = pages.map { |page| get_products_by_page(page) }
      else
        items = [get_products]
      end

      return 'Нет товаров' if items.blank?

      items.each_with_index do |item, page_num |
        item.each_with_index do |product, idx|
          position = idx + 1
          page_number = page_num
          id = product['id']
          price_full = product['priceU'] / 100
          price_discount = product['salePriceU'] / 100
          category_id = product['subjectId']
          sale_name = product['promoTextCard']

          @product = Product.find_by(sku: id)
          # https://static-basket-01.wb.ru/vol0/data/subject-base.json

          if @product.present? && @product.webapi_data.blank?
            @product.webapi_data = product
            @product.save
          end

          if @product.blank?
            category = Category.find_by(cat_id: category_id)
            next if category.blank?

            @product = Product.create!(sku: id, webapi_data: product, name: product['name'], category_id: category.id)

            @product.data.merge!(position: position, page_number:)
            @product.save

            Rails.logger.info("New Product created: #{@product.attributes}")
          end

          if @product.prices.count == 0
            @product.prices.create!(data: { price_discount:, price_full: })
          elsif @product.prices.last.price_discount > price_discount
            price_diff = @product.prices.last.price_discount - price_discount
            b = (@product.prices.last.price_discount + price_discount) / 2

            new_price = @product.prices.create!(data: { price_discount:, price_full: })

            # (a — b) / [ (a + b) / 2 ] | * 100 %
            price_percent = (price_diff / b.to_f) * 100

            discount = Discount.create!(price: new_price,
                                        product: @product,
                                        price_diff:,
                                        price_percent:,
                                        data: { sale_name: })

            price_changed << {
              name: @product.name,
              link: @product.link,
              category: @product.category.name,
              old_price: @product.prices.last(2).first.price_discount,
              new_price: @product.prices.last.price_discount,
              price_diff:,
              image_url: @product.image_url,
              discount_id: discount.id
            }

            Rails.logger.info("Price changed for product: #{discount}")
          end
        end
      end
    end

    private

    def get_products_by_page(page)
      Rails.logger.debug("Starting parsing #{query} with page number: #{page} ")
      Wb::Query::Search.run!(query: query, page: page)
    end

    def get_products
      Rails.logger.debug("Starting parsing #{query} with page number: 1")
      Wb::Query::Search.run!(query: query)
    end

  end
end