module Wb
  class DiscountsCheck < ActiveInteraction::Base
    CHAT_ID = '-1001987307657'.freeze

    string :query
    integer :notify_price
    array :pages, default: nil

    def execute
      price_changed = []

      if pages.present?
        items = pages.map { |page| get_products_by_page(page) }
      else
        items = [get_products]
      end

      return 'Нет товаров' if items.blank?

      items.each_with_index do |item, page_num|
        item.each_with_index do |product, idx|
          position = idx + 1
          page_number = page_num + 1
          id = product['id']
          price_full = product['priceU'] / 100
          price_discount = product['salePriceU'] / 100
          subject_id = product['subjectId']
          sale_name = product['promoTextCard']

          @product = Product.find_by(sku: id)
          # https://static-basket-01.wb.ru/vol0/data/subject-base.json

          if @product.present? && @product.webapi_data.blank?
            @product.webapi_data = product
            @product.save
          end

          if @product.blank?
            subject = Subject.find_by(cat_id: subject_id)
            next if subject.blank?

            @product = Product.create!(sku: id, webapi_data: product, name: product['name'], subject_id: subject.id)

            @product.data.merge!(position: position, page_number:)
            @product.save

            Rails.logger.info("New Product created in #{subject.name}: #{@product.name} ")
            Wb::ParseProductWorker.perform_async(@product.sku)
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
              subject: @product.subject.name,
              old_price: @product.prices.last(2).first.price_discount,
              new_price: @product.prices.last.price_discount,
              price_diff:,
              image_urls: @product.data['images']&.first(3),
              price_history: @product.data['price_history'],
              product_rating: @product.webapi_data['reviewRating'],
              sale_name: @product.data['promoTextCat'],
              sku: @product.webapi_data['id'],
              sells_count: @product.data['sells_count'],
              store_url: @product.data['store_url'],
              feedbacks_count: @product.webapi_data['feedbacks'],
              colors: @product.webapi_data['colors'].map { |c| c['name'] }.join(', '),
              discount_id: discount.id,
              brand: @product.webapi_data['brand']
            }

            Rails.logger.info("Price changed for product: #{discount}")
          end
        end
      end

      notify = price_changed.select { |p| p[:price_diff] >= notify_price }

      notify.each do |product_info|
        if product_info[:image_urls].present?
          media = product_info[:image_urls].map.with_index do |image_url, idx|
            if idx == 0
              { type: 'photo',
                media: image_url,
                caption: product_text(product_info),
                parse_mode: 'HTML'
              }
            else
              { type: 'photo',
                media: image_url }
            end
          end

          Telegram.bot.send_media_group(
            chat_id: CHAT_ID,
            media: media,
          )

          # Telegram.bot.send_photo(
          #   chat_id: User.last.chat_id, caption: product_text(product_info), photo: product_info[:image_url], parse_mode: 'HTML',
          #   reply_markup: { inline_keyboard: [
          #     [{ text: 'Посмотреть товар', url: product_info[:link] }],
          #   ],
          #   })
          # else
          # Telegram.bot.send_message(chat_id: User.last.chat_id, text: product_text(product_info), parse_mode: "HTML")
        end

        discount = Discount.find_by(id: product_info[:discount_id])
        discount.update(notify: true, notify_at: Time.now) if discount.present?
      end

      puts "-------------------------------------------"
      puts "INFO: price changed count: #{price_changed.count}"
      puts "price notify: #{notify.count}"
      puts "-------------------------------------------"
    end

    private

    def product_text(product_data)
      text = []
      text << "🔥 <b>Выгода: #{product_data[:price_diff]}₽</b> \n"

      text << "🏘 <b>Акция: </b> #{product_data[:sale_name]}\n \n" if product_data[:sale_name]

      text << "💰 <b>Цена: </b>#{product_data[:new_price]}₽ ❗ <s>#{product_data[:old_price]}₽</s> ️  \n\n"

      # text << "🏷 <b>Категория: </b> #{product_data[:subject]} \n"
      text << "🛍 <b>Товар: </b> #{product_data[:name]} \n"
      text << "🏷 <b>Бренд: </b> <a href='#{product_data[:store_url]}'>#{product_data[:brand]}</a>\n\n"

      text << "🆔 <b>Артикул: </b> #{product_data[:sku]} \n"
      text << "🏳 <b>Цвета: </b>#{product_data[:colors]} \n\n"

      text << "👍 <b>Рейтинг: </b>#{product_data[:product_rating]} \n"
      text << "🗣️️ <b>Отзывы: </b>#{product_data[:feedbacks_count]} \n"
      text << "🔴 #{product_data[:sells_count]} \n\n"

      text << "👉 <a href='#{product_data[:link]}'>Товар на Wildberries</a> \n"

      # text << "📈 <b>История цены: </b>#{product_data[:price_history]}₽ \n" if product_data[:price_history]

      text.join
    end

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