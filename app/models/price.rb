class Price < ApplicationRecord
  belongs_to :product
  has_many :discounts, dependent: :destroy

  store_accessor :data, :price_discount, :price_full

  # after_commit :notify

  def notify
    Telegram::Notifications::AdsApi.new(self).call
  end

  def diff
    { old: old, new: price_discount}
  end

  def old
    product.prices[-2].try(:price_discount)
  end
end
