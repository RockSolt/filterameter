# frozen_string_literal: true

module Filterameter
  module Filters
    # = Nested Attribute Filter
    #
    # Class NestedFilter joins the nested table(s) then merges the filter to the association's model.
    class NestedFilter
      # = Joins Values Builder
      #
      # Class JoinsValuesBuilder evaluates an array of names to return either the single entry when there is only
      # one element in the array or a nested hash when there is more than one element. This is the argument that is
      # passed into the ActiveRecord query method `joins`.
      class JoinsValuesBuilder
        def self.build(association_names)
          return association_names.first if association_names.size == 1

          new(association_names).to_h
        end

        def initialize(association_names)
          @association_names = association_names
        end

        def to_h
          {}.tap do |nested_hash|
            @association_names.reduce(nested_hash) { |memo, name| memo.store(name, {}) }
          end
        end
      end

      def initialize(association_names, association_model, attribute_filter)
        @joins_values = JoinsValuesBuilder.build(association_names)
        @association_model = association_model
        @attribute_filter = attribute_filter
      end

      def apply(query, value)
        query.joins(@joins_values)
             .merge(@attribute_filter.apply(@association_model.all, value))
      end
    end
  end
end
