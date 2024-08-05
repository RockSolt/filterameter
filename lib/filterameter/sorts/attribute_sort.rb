# frozen_string_literal: true

module Filterameter
  module Sorts
    # # Attribute Sort
    #
    # Class AttributeSort leverages ActiveRecord's `order` query method to add sorting for an attribute.
    class AttributeSort
      include Filterameter::Errors
      include Filterameter::Filters::AttributeValidator

      def initialize(attribute_name)
        @attribute_name = attribute_name
      end

      def apply(query, direction)
        query.order(@attribute_name => direction)
      end
    end
  end
end
