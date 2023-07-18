module Groupable
  extend ActiveSupport::Concern

  included do
    scope :between_range, -> (date_range) { where(date: date_range).order('DATE(date)') }
    scope :grouped_by_date, -> (date_range) { between_range(date_range).group('DATE(date)').count }
    scope :grouped_by_price, -> (date_range) { between_range(date_range).group('DATE(date)').sum("(api_data->>'finishedPrice')::float") }
    scope :grouped_by_month, -> (date_range) { between_range(date_range).group('date_trunk(week, date)').count }
  end

  class_methods do
    def group_by_date_with_zero(date_range:, type: nil)
      days_range = date_range.begin.to_date..date_range.end.to_date

      records_grouped_by_date =
        case type
        when :by_price
          grouped_by_price(date_range)
        when :by_date
          grouped_by_date(date_range)
        when :by_month
          grouped_by_month(date_range)
        else
          grouped_by_date(date_range)
        end

      days_range.each_with_object({}) do |date, result|
        result[date.to_s] = records_grouped_by_date[date].to_i || 0
      end
    end
  end
end