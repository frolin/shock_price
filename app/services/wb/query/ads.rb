module Wb
  module Query
    class Ads < BrowserApi
      string :keyword

      def execute
        response
      end

      private

      def base_url
        'https://catalog-ads.wildberries.ru/'
      end

      def api_method
        'api/v6/search'
      end

      def type
        :get
      end

      def params
        { keyword: keyword }
      end
    end
  end
end

