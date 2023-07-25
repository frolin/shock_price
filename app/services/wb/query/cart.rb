

module Wb
  module Query
    class Cart < BrowserApi
      string :skus

      def execute
        response
      end

      private

      def base_url
        'https://card.wb.ru/'
      end

      def api_method
        'cards/list/'
      end

      def type
        :get
      end

      def params
        {
          appType: 1,
          curr: 'rub',
          regions: '80,38,83,4,64,33,68,70,30,40,86,75,69,22,1,31,66,110,48,71,114',
          nm: skus
        }
      end
    end
  end
end

