module Wb
  module Query
    class Catalog < BrowserApi
      string :query
      integer :page, default: nil

      def execute
        JSON.parse(response).dig('data', 'products')
      end

      private

      def base_url
        # https://catalog.wb.ru/catalog/shorts/catalog?
        'https://search.wb.ru/'
      end

      def api_method
        'exactmatch/ru/common/v4/search'
      end

      def type
        :get
      end

      def params
        # https://catalog.wb.ru/catalog/bl_shirts/catalog?appType=1&cat=8126&curr=rub&dest=123585480&regions=80,38,83,4,64,33,68,70,30,40,86,75,69,22,1,31,66,110,48,71,114&sort=popular&spp=0&uclusters=0

        {
          TestGroup: 'no_test',
          TestID: 'no_test',
          appType: 1,
          query: query,
          curr: 'rub',
          regions: '80,38,83,4,64,33,68,70,30,40,86,75,69,22,1,31,66,110,48,71,114',
          uclusters: 0,
          spp: 0,
          sort: 'popular',
          dest: -1257786,
          resultset: 'catalog'
        }
      end
    end
  end
end

