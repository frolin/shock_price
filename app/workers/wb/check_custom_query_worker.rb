module Wb
  class CheckCustomQueryWorker
    include Sidekiq::Worker
    
    def perform
      cosmetics = ['Бальзам для губ', 'Бальзам для губ', 'Твердый бальзам для волос', 'Крем для рук и тела', 'Твердое масло для тела' ]
      clothes = ['Шуба женская', 'Шуба зимняя искусственна', 'Шапка бини', 'Свитер вязаный оверсайз']
      gifts = ['Открытки набор', 'Фотофон Газета', 'стильные картины по номерам', 'Подсвечник декоративный', 'Наволочка декоративная', 'Свеча ароматическая в банке', 'Брелок для ключей женский', 'Журнал Seasons of life', 'Журналы']
      
      queries.each do |name|
        ::Wb::CheckDiscountsWorker.perform_async(name, 'женщины', [1], 30)
      end

       ::Wb::CheckDiscountsWorker.perform_async('Товары для уборки', 'женщины', [1,2,3,4,5], 50)
       ::Wb::CheckDiscountsWorker.perform_async('Маникюр', 'женщины', [1,2,3], 30)
    end
  end
end
