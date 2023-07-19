require 'net/http'
require 'tempfile'
require 'uri'

module Wb
  module Discounts
    class Importer < ActiveInteraction::Base
      CHAT_ID='-1001987307657'.freeze

      array :products_data

      def execute
        price_changed = []

        products_data.each do |product_data|
          product_data.symbolize_keys!
          sku = product_data.delete(:sku)
          price_discount = product_data.delete(:price_discount)&.split(' ')&.join.to_i
          price_full = product_data.delete(:price_full)&.split(' ')&.join.to_i
          product_name = product_data.delete(:product_name)
          sale_name = product_data.delete(:sale_name)
          category_id = product_data.delete(:category_id)

          @product = Product.find_by(sku: sku)

          if @product.blank?
            @product = Product.create!(sku: sku, data: product_data, name: product_name, category_id:)

            Rails.logger.info("New Product created: #{@product.attributes}")
          end

          if @product.image_url.present?
            @product.data.merge!(image_url: product_data[:image_url])
            @product.save!
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

        notify = price_changed.select { |p| p[:price_diff] > 400 }

        notify.each do |product_info|
          if product_info[:image_url].present?
            Telegram.bot.send_photo(chat_id: CHAT_ID,
                                    caption: product_text(product_info), photo: product_info[:image_url], parse_mode: 'HTML')

          else
            Telegram.bot.send_message(chat_id: CHAT_ID, text: product_text(product_info), parse_mode: "HTML")
          end

          discount = Discount.find_by(id: product_info[:discount_id])
          discount.update(notify: true) if discount.present?
        end

        puts "-------------------------------------------"
        puts "INFO: price changed count: #{price_changed.count}"
        puts "price notify: #{notify.count}"
        puts "-------------------------------------------"
      end

      def save_to_tempfile(url)
        uri = URI.parse(url)
        file = Tempfile.new('foo', Dir.tmpdir)
        Net::HTTP.start(uri.host, uri.port) do |http|
          resp = http.get(uri.path)
          file.binmode
          file.write(resp.body)
          file.flush
        end

        file
      end

      def product_text(product_data)
        text = []

        text << "\n 🏷 <b>Категория: </b> #{product_data[:category]} \n\n"
        text << "🛍️ <b>Товар: </b> <a href='#{product_data[:link]}'>#{product_data[:name]}</a> \n\n"

        text << "❗ <b> Цена: </b> #{product_data[:old_price]} ₽  ➡ ️ #{product_data[:new_price]} ₽ \n\n"

        text << "🔥 <b> Выгода: </b> #{product_data[:price_diff]} ₽ \n "

        text.join
      end
    end
  end
end