class Category < ApplicationRecord
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "Category", foreign_key: "parent_id", optional: true

  has_many :products

  scope :with_subcategories, -> { where.not(parent_id: nil) }
  scope :parents, -> { where(parent_id: nil) }

  scope :women, -> { find(21).subcategories.pluck(:name) }
end
