# frozen_string_literal: true

module Filterameter
  module Filters
    # # Nested Collection Filter
    #
    # Class NestedCollectionFilter joins the nested table(s), merges the filter to the association's model, then makes
    # the results distinct.
    class NestedCollectionFilter < NestedFilter
      def apply(*)
        super.distinct
      end
    end
  end
end
