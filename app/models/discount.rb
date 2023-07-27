class Discount < ApplicationRecord
  include Groupable

  belongs_to :product
  belongs_to :price

  scope :today, -> { where(created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day) }
  store_accessor :data, :sale_name

  def diff
    price.diff
  end

end
