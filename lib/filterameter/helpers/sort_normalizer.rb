# frozen_string_literal: true

module Filterameter
  module Helpers
    # Normalizes the hash representation used for declared and current sorts.
    module SortNormalizer
      module_function

      def normalize(sort)
        return if sort.nil?
        raise ArgumentError, 'default_sort must be a hash of sort names and directions' unless sort.is_a?(Hash)

        sort.each_with_object({}) do |(name, direction), result|
          result[name.to_sym] = SortSerializer.normalize_direction(direction)
        end
      end
    end
  end
end
