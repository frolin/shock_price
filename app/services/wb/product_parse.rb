module Wb
  class ProductParse < ActiveInteraction::Base
    SEARCH_CSS = {
      images: '.j-zoom-image',
      reviews_count: '.product-review__count-review',
      questions_count: '#a-Questions',
      rating: '.user-opinion__rating',
      title: 'h1',
      final_price: '.price-block__final-price',
      seller_url: '.seller-info__name--link',
      price_history: '.price-history__text',
      sells_count: '.product-order-quantity',
      description: '.product-page__details-section .details-section__inner-wrap'
    }

    string :sku
    string :last, default: nil
    attr_reader :image_urls, :reviews_count, :questions_count, :rating, :title, :final_price, :store_url

    def execute
      # return if search.invalid?

      @page = search

      begin
        # @page.save_screenshot("#{Rails.public_path}/#{title}.png")

        # scroll page

        sleep 1
        images = find_images
        sleep 1

        @page.execute_script('window.scrollBy(0, 1500)')

        {
          store_url: find_store_url,
          images: images,
          reviews_count: reviews_count,
          questions_count: questions_count,
          rating: find_rating,
          url: @page.current_url,
          title: find_title,
          price_history: price_history,
          sells_count: find_sells_count,
          description: find_description,
          final_price: final_price
        }.compact
      ensure
        @page.close
      end
    end

    private

    def search
      ::Browser.new("https://www.wildberries.ru/catalog/#{sku}/detail.aspx?targetUrl=GP").run
    end

    def find_images
      find_element(type: :css, name: SEARCH_CSS[:images]) do
        @page.find_element(css: '.zoom-image-container').click
        sleep 1
        images = @page.find_elements(css: SEARCH_CSS[:images]).map { |image| image.attribute('src') }

        sleep 1
        @page.find_element(css: '.j-close.popup__close').click

        images
      end
    end

    def find_questions
      find_element(type: :css, name: SEARCH_CSS[:questions_count]) do
        @page.find_element(css: SEARCH_CSS[:questions_count]).text.to_i
      end
    end

    def find_rating
      find_element(type: :css, name: SEARCH_CSS[:rating]) do
        @page.find_element(css: SEARCH_CSS[:rating]).text.to_f
      end
    end

    def find_title
      find_element(type: :css, name: SEARCH_CSS[:title]) do
        @page.find_element(css: SEARCH_CSS[:title]).text
      end
    end

    def find_final_price
      return if @page.find_elements(css: '.sold-out-product').present?

      wait.until do
        if @page.find_element(css: SEARCH_CSS[:final_price]).text.present?
          @page.find_element(css: SEARCH_CSS[:final_price]).text
        end
      end
    end

    def find_review_count
      find_element(type: :css, name: SEARCH_CSS[:reviews_count]) do
        @page.find_element(css: SEARCH_CSS[:reviews_count]).text.to_i
      end
    end

    def find_store_url
      find_element(type: :css, name: SEARCH_CSS[:seller_url]) do
        @page.find_element(css: SEARCH_CSS[:seller_url]).attribute('href')
      end
    end

    def find_sells_count
      find_element(type: :css, name: SEARCH_CSS[:sells_count]) do
        @page.find_element(css: SEARCH_CSS[:sells_count]).text
      end
    end

    def find_description
      find_element(type: :css, name: SEARCH_CSS[:description]) do
        @page.find_element(css: SEARCH_CSS[:description]).text
      end
    end

    def price_history
      find_element(type: :css, name: SEARCH_CSS[:price_history]) do
        @page.find_element(css: SEARCH_CSS[:price_history]).text
      end
    end

    def find_element(type:, name:)
      begin
        element_found = wait.until do
          element_is_displayed?(type: type, name: name)
        end

        yield if block_given? && element_found
      rescue StandardError
        nil
      end
    end

    def element_is_displayed?(type:, name:)
      @page.find_elements(type => name).present? ? true : false
    end

    def wait
      Selenium::WebDriver::Wait.new(timeout: 30)
    end
  end
end
