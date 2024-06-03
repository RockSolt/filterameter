# frozen_string_literal: true

module Filterameter
  module Filters
    # = Nested Attribute Filter
    #
    # Class NestedFilter joins the nested table(s) then merges the filter to the association's model.
    class NestedFilter
      def initialize(association_names, association_model, attribute_filter)
        @joins_values = build_joins_values_argument(association_names)
        @association_model = association_model
        @attribute_filter = attribute_filter
      end

      def apply(query, value)
        query.joins(@joins_values)
             .merge(@attribute_filter.apply(@association_model.all, value))
      end

      private

      def build_joins_values_argument(association_names)
        return association_names.first if association_names.size == 1

        convert_to_nested_hash(association_names)
      end

      def convert_to_nested_hash(association_names)
        {}.tap do |nested_hash|
          association_names.reduce(nested_hash) { |memo, name| memo.store(name, {}) }
        end
      end
    end
  end
end
