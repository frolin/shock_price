class DiscountsController < ApplicationController
  def index
    @discounts_by_category = Discount.joins(product: :subject)
                                     .select('DISTINCT ON (categories.name) discounts.*, categories.name AS subject_name')
                                     .group('categories.name, discounts.id')

    @discounts_by_sub_category = Discount.today.includes(product: :subject)

    @discounts = Discount.today.includes(:product, :price).order('price_diff desc')
  end
end
