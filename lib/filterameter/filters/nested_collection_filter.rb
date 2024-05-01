# frozen_string_literal: true

module Filterameter
  module Filters
    # = Nested Collection Filter
    #
    # Class NestedCollectionFilter uses a sub-query to find matching rows in the collection association.
    #
    # For example, if a Brand has many Shirts, the following SQL is generated:
    #
    #   SELECT "brands".*
    #   FROM "brands"
    #   WHERE "brands"."id" IN (
    #     SELECT "shirts"."brand_id" FROM "shirts" WHERE "shirts"."color" = 'blue'
    #   )
    class NestedCollectionFilter
      def initialize(foreign_key, association_model, attribute_filter)
        @foreign_key = foreign_key
        @association_model = association_model
        @attribute_filter = attribute_filter
      end

      def apply(query, value)
        sub_query = @attribute_filter.apply(@association_model, value)
        query.where(id: sub_query.select(@foreign_key).distinct)
      end
    end
  end
end
