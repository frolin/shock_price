class Product < ApplicationRecord
  has_many :prices, dependent: :destroy
  belongs_to :category
  has_many :discounts

  store_accessor :data, :image_url

  def url
    data['url']
  end

  def weight
    data['product_weight']
  end

  def link
    data['link']
  end
end
