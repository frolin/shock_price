module Wb
  module Query
    class Catalog < BrowserApi
      record :category

      def execute
        response.dig('data', 'products')
      end

      private

      def base_url
        # https://catalog.wb.ru/catalog/shorts/catalog?
        'https://catalog.wb.ru/'
      end

      def api_method
        category
      end

      def type
        :get
      end

      def params
        {
          appType: 1,
          cat: cat_id,
          curr: 'rub',
          regions: '80,38,83,4,64,33,68,70,30,40,86,75,69,22,1,31,66,110,48,71,114',
          uclusters: 0,
          spp: 0,
          sort: 'popular',
          dest: -1257786,
        }
      end
    end
  end
end

