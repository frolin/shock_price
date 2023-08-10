class Category < ApplicationRecord
  GADGET_CATEGORY_NAMES = ['Развлечения и гаджеты', '3D-печать', 'Оборудование для презентаций',
                           'Аксессуары для напитков','Периферийные ксессуары', 'Измельчение и смешивание'].freeze

  has_many :keywords

  scope :gadgets, -> { where(name: GADGET_CATEGORY_NAMES) }
end
