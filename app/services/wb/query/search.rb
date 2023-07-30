module Wb
  module Query
    class Search < BrowserApi
      string :query
      integer :page, default: nil

      def execute
        errors.add(:base, 'empty response') if response.blank?

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
        {
          TestGroup: 'test_1',
          query: query,
          spp: 30,
          appType: 1,
          curr: 'rub',
          regions: '80,38,83,4,64,33,68,70,30,40,86,75,69,22,1,31,66,110,48,71,114',
          uclusters: 0,
          sort: 'popular',
          dest: -1257786,
          resultset: 'catalog',
          suppressSpellcheck: false,
          page: page || 1
        }
      end
    end
  end
end

