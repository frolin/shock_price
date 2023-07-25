class Product < ApplicationRecord
  belongs_to :category
  has_many :discounts, dependent: :destroy
  has_many :prices, dependent: :destroy

  # store_accessor :data, :image_url

  def url
    data['url']
  end

  def weight
    data['product_weight']
  end

  def link
    data['url']
  end

  def images_url
    data['images']
  end
end
