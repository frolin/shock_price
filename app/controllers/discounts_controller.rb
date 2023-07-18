class DiscountsController < ApplicationController
  def index
    @discounts_by_category = Discount.joins(product: :category)
                                     .select('DISTINCT ON (categories.name) discounts.*, categories.name AS category_name')
                                     .group('categories.name, discounts.id')

    @discounts_by_sub_category = Discount.today.includes(product: :category)

    @discounts = Discount.today.includes(:product, :price).order('price_diff desc')
  end
end
