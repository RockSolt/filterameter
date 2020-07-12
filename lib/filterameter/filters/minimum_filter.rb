# frozen_string_literal: true

module Filterameter
  module Filters
    # = Minimum Filter
    #
    # Class MinimumFilter adds criteria for all values greater than or equal to a minimum.
    class MinimumFilter < ArelFilter
      def apply(query, value)
        query.where(@arel_attribute.gteq(value))
      end
    end
  end
end
