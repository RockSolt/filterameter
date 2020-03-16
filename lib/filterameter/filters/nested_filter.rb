# frozen_string_literal: true

module Filterameter
  module Filters
    # = Nested Attribute Filter
    #
    # Class NestedFilter joins the nested table(s) then merges the filter to the association's model.
    class NestedFilter
      def initialize(joins_values, association_model, attribute_filter)
        @joins_values = joins_values
        @association_model = association_model
        @attribute_filter = attribute_filter
      end

      def apply(query, value)
        query.joins(@joins_values)
             .merge(@attribute_filter.apply(@association_model, value))
      end
    end
  end
end
