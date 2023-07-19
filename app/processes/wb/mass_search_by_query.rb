require "selenium-webdriver"

module Wb
  class MassSearchByQuery < ActiveInteraction::Base
    INPUT_FORM = '#searchInput'
    PROMO = '.product-card__tip.product-card__tip--action'
    BRAND_NAME = 'span.product-card__brand'
    PRODUCT_NAME = 'span.product-card__name'
    RATING = '.address-rate-mini'
    REVIEWS_COUNT = '.product-card__count'
    PRICE_DISCOUNT = '.price__wrap .price__lower-price'
    PRICE_FULL = '.price__wrap del'
    SALE_NAME = '.product-card__tips--bottom .product-card__tip--action'
    IMAGE = '.product-card__img-wrap img'
    WOMEN_CATEGORY = ''
    MAX_PAGE_NUMBER = 3

    record :category

    def execute
      cards = []

      @wait = Selenium::WebDriver::Wait.new(timeout: 60)
      # search
      @page = Browser.new(category.url).run
      @page_number = 1

      begin
        time = Benchmark.measure {
          loop do
            break "max page, exit" if @page_number == MAX_PAGE_NUMBER
            Rails.logger.info "Категория: #{category.name}, URL: #{category.url}"

            @current_page_number = @page_number
            # puts "Start new iteration with query: #{keyword.name}"

            @wait.until do
              while @page.find_elements(css: ".product-card-list .product-card").count <= 90
                sleep(0.5)
                @page.execute_script("window.scrollBy(0,100)")
              end
              # rescue => e
              #   byebug
              #   @page.execute_script("window.location.reload()")

              puts 'Collecting data...'
              @page.find_elements(css: ".product-card-list .product-card").each_with_index do |card, idx|
                card = data(card, idx + 1).merge!(category_id: category.id)
                cards << card
              end

              Wb::DiscountImporterWorker.perform_async(cards.to_json)
            end

            goto_next_page
          end
        }

        puts time.real
      ensure
        @page.quit
      end
    end

    private

    # def first_page
    #   "https://www.wildberries.ru/catalog/0/search.aspx?page=#{1}&sort=popular&search=#{keyword.name}"
    # end

    def search
      search = @wait.until {
        element_is_displayed?(type: :css, name: INPUT_FORM)
      }

      if search
        search_form = @page.find_element(css: '#searchInput')
        sleep(3)

        search_form.send_keys(keyword.name)
        search_form.send_keys(:return)
      else
        raise Selenium::WebDriver::Error::NoSuchElementError
      end

    end

    def changed_position?(keyword_result, product_data)
      keyword_result.present? && product_data[:position].present? &&
        keyword_result.absolute_position != product_data[:absolute_position]
    end

    def element_is_displayed?(type:, name:)
      @page.find_elements(type => name).present? ? true : false
    end

    def goto_next_page
      @page_number += 1
      # @page.navigate.to("https://www.wildberries.ru/catalog/0/search.aspx?page=#{number}&sort=popular&search=#{keyword.name}")
      next_page = @page.find_elements(css: 'a.pagination-item').select { |el| el.text == next_page_number }.first
      next_page_url = next_page.attribute(:href)

      @page.navigate.to(next_page_url)
    end

    def current_page_number
      @current_page_number
      # @page.find_element(css: '.pagination__item.active').text
    end

    def next_page_number
      (current_page_number.to_i + 1).to_s
    end

    def data(product, position)
      { page_number: current_page_number.to_i,
        absolute_position: absolute_index(position),
        position: position,
        brand_name: product.find_element(css: BRAND_NAME).text.squish,
        product_name: product.find_element(css: PRODUCT_NAME).text.tr('/', '').squish,
        rating: rating(product),
        reviews: reviews(product),
        price_discount: price_discount(product),
        price_full: price_full(product),
        product_weight: rating(product) / reviews(product),
        url: @page.current_url,
        image_url: image(product),
        ads: ads?(product),
        sale_name: sale_name(product),
        sku: product.attribute('id').gsub('c', ''),
        link: product.find_element(css: 'a').attribute('href') }
    end

    def absolute_index(position)
      if current_page_number == 1
        position
      else
        current_page_number.to_i * 100 + position
      end
    end

    def rating(product)
      product.find_element(css: RATING).text.squish.to_f
    rescue
      nil
    end

    def reviews(product)
      product.find_element(css: REVIEWS_COUNT).text.to_i
    rescue
      nil
    end

    def price_discount(product)
      product.find_element(css: PRICE_DISCOUNT).text
    rescue
      nil
    end

    def sale_name(product)
      product.find_element(css: SALE_NAME).text
    rescue
      nil
    end

    def image(product)
      product.find_element(css: IMAGE).attribute('src')
    rescue
      nil
    end

    def price_full(product)
      product.find_element(css: PRICE_FULL).text
    rescue
      nil
    end

    def ads?(product)
      product.find_element(css: PROMO).text.downcase == 'промотовар'
    rescue
      false
    end
  end
end