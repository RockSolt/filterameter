# frozen_string_literal: true

module Filterameter
  module Filters
    # # Maximum Filter
    #
    # Class MaximumFilter adds criteria for all values greater than or equal to a maximum.
    class MaximumFilter < ArelFilter
      def apply(query, value)
        query.where(@arel_attribute.lteq(value))
      end
    end
  end
end
