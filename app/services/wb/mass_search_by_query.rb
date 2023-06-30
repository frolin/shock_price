require "selenium-webdriver"

module Wb
  class MassSearchByQuery < ActiveInteraction::Base
    INPUT_FORM = '#searchInput'
    PROMO = '.product-card__tip.product-card__tip--action'
    MAX_PAGE_NUMBER = 5

    record :keyword

    def execute
      ads = []
      data_all = []

      @wait = Selenium::WebDriver::Wait.new(timeout: 60)
      # search
      @page = Browser.new(first_page).run
      @page_number = 1

      begin
        loop do
          break "max page, exit" if @page_number == MAX_PAGE_NUMBER

          @current_page_number = @page_number
          puts "Start new iteration with query: #{keyword.name}"

          while @page.find_elements(css: ".product-card.j-card-item").count != 100
            sleep(0.3)
            @page.execute_script("window.scrollBy(0,100)")
          end


          @page.find_elements(css: ".product-card.j-card-item").each_with_index do |product, idx|
            if ads?(product)
              ads << product
              next
            end

            product_data = data(product, idx + 1)
            keyword_result = KeywordResult.find_by(sku: product_data[:sku])

            if changed_position?(keyword_result, product_data)
              keyword_result.update!(data: product_data)
              next
            elsif keyword_result
              next
            else
              KeywordResult.create!(sku: product_data.delete(:sku),
                                    page_number: product_data.delete(:page_number),
                                    keyword_id: keyword.id,
                                    data: product_data)
            end
          end

          goto_next_page(@page_number)
          @page_number += 1

          puts "goto next page num from: #{@current_page_number} to: #{@page_number} "
        end

      ensure
        @page.quit
      end
    end

    private

    def first_page
      "https://www.wildberries.ru/catalog/0/search.aspx?page=#{1}&sort=popular&search=#{keyword.name}"
    end

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

    def goto_next_page(number)
      @page.navigate.to("https://www.wildberries.ru/catalog/0/search.aspx?page=#{number}&sort=popular&search=#{keyword.name}")
      # @page.find_elements(css: 'a.pagination-item').select { |el| el.text == next_page_number }.first
    end


    def current_page_number
      @current_page_number
      # @page.find_element(css: '.pagination__item.active').text
    end

    # def next_page_number
    #   (current_page_number.to_i + 1).to_s
    # end

    def data(product, position)
      { page_number: current_page_number.to_i,
        absolute_position: absolute_index(position),
        position: position,
        brand_name: product.find_element(css: '.brand-name').text,
        product_name: product.find_element(css: '.goods-name').text,
        url: @page.current_url,
        ads: ads?(product),
        sku: product.attribute('id').gsub('c', ''),
        description: product.find_element(css: 'a').text.split("\n"),
        link: product.find_element(css: 'a').attribute('href') }
    end

    def absolute_index(position)
      if current_page_number == '1'
        position
      else
        current_page_number.to_i * 100 + position
      end
    end

    def ads?(product)
      product.find_element(css: PROMO).text.downcase == 'промотовар'
    rescue
      false
    end
  end
end