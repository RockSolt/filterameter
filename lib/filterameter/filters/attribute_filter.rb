# frozen_string_literal: true

module Filterameter
  module Filters
    # = Attribute Filter
    #
    # Class AttributeFilter leverages ActiveRecord's where query method to add criteria for an attribute.
    class AttributeFilter
      include Filterameter::Errors
      include AttributeValidator

      def initialize(attribute_name)
        @attribute_name = attribute_name
      end

      def apply(query, value)
        query.where(@attribute_name => value)
      end
    end
  end
end
