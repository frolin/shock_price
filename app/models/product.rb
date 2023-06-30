class Product < ApplicationRecord
  has_many :prices
  belongs_to :category
end
