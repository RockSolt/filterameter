# frozen_string_literal: true

module Filterameter
  module Filters
    # = Arel Filter
    #
    # Class ArelFilter is a base class for arel queries. It does not implement <tt>apply</tt>.
    class ArelFilter
      def initialize(model, attribute_name)
        @arel_attribute = model.arel_table[attribute_name]
      end
    end
  end
end
