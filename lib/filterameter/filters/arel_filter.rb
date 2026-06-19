# frozen_string_literal: true

module Filterameter
  module Filters
    # # Arel Filter
    #
    # Class ArelFilter is a base class for arel queries. It does not implement
    # `apply`.
    class ArelFilter
      include Filterameter::Errors
      include Filterameter::Filters::AttributeValidator

      def initialize(model, attribute_name, &converter)
        @attribute_name = attribute_name
        @arel_attribute = model.arel_table[attribute_name]
        @converter = converter
      end
    end
  end
end
