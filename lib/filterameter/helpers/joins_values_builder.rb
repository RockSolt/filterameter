# frozen_string_literal: true

module Filterameter
  module Helpers
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
  end
end
