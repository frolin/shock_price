class AddKitchenKeywords < ActiveRecord::Migration[7.0]
  def change
    kitchen_keywords = ['хранение вещей органайзеры', 'хранение вещей', 'Уход для губ', 'Уход за лицом',
                        'крем для тела', 'скраб для тела', 'уход за зубами', 'Гаджеты для дома',
                        'Корейская косметика', 'Мыло', 'Моющие средства']


    category = Category.find_by!(name: 'Кухня')
    kitchen_keywords.each { |k| Keyword.create(name: k, category: category) }
  end
end
