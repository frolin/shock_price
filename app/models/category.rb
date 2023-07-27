class Category < ApplicationRecord
  SUB_CATEGORIES = { women: 'Женщины', home: 'Дом', kitchen: 'Кухня' }

  has_many :subcategories, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "Category", foreign_key: "parent_id", optional: true

  has_many :products

  scope :with_subcategories, -> { where.not(parent_id: nil) }
  scope :parents, -> { where(parent_id: nil) }

  scope :women, -> { find_by(name: SUB_CATEGORIES[:women]).subcategories.pluck(:name) }
  scope :home, -> { find_by(name: SUB_CATEGORIES[:home]).subcategories.pluck(:name) }
  scope :kitchen, -> { find_by(name: SUB_CATEGORIES[:home]).subcategories.pluck(:name) }
end
