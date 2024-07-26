# frozen_string_literal: true

module Filterameter
  module Filters
    # = Nested Attribute Filter
    #
    # Class NestedFilter joins the nested table(s) then merges the filter to the association's model.
    class NestedFilter
      include Filterameter::Errors

      def initialize(association_names, association_model, attribute_filter)
        @joins_values = Filterameter::Helpers::JoinsValuesBuilder.build(association_names)
        @association_model = association_model
        @attribute_filter = attribute_filter
      end

      def apply(query, value)
        query.joins(@joins_values)
             .merge(@attribute_filter.apply(@association_model.all, value))
      end

      private

      def validate(model)
        @errors.push(*@attribute_filter.errors) unless @attribute_filter.valid?(@association_model)
        validate_associations(model)
      end

      def validate_associations(model)
        model.joins(@joins_values).to_sql
      rescue ActiveRecord::ConfigurationError => e
        @errors << e.message
      end
    end
  end
end
