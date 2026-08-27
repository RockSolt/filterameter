# frozen_string_literal: true

module Filterameter
  module Helpers
    # # Sort Serializer
    #
    # Handles conversion between sort string representation and hash representation.
    #
    # String format follows standard conventions:
    # - "name" or "+name" for ascending
    # - "-name" for descending
    #
    # Hash format:
    # - { name: :asc } for ascending
    # - { name: :desc } for descending
    module SortSerializer
      module_function

      # Converts a sort string to a hash with name and direction
      #
      # @param sort_string [String] the sort string (e.g., "name", "-name")
      # @return [Hash] hash with :name and :direction keys
      #
      # @example
      #   deserialize("name")     #=> { name: "name", direction: :asc }
      #   deserialize("-name")    #=> { name: "name", direction: :desc }
      def deserialize(sort_string)
        parsed = sort_string.to_s.match(/(?<sign>[+|-]?)(?<name>\w+)/)
        {
          name: parsed['name'],
          direction: parsed['sign'] == '-' ? :desc : :asc
        }
      end

      # Converts a name and direction to a sort string
      #
      # @param name [String, Symbol] the sort field name
      # @param direction [Symbol, String] the sort direction (:asc or :desc)
      # @return [String] the serialized sort string
      # @raise [ArgumentError] if direction is not :asc or :desc
      #
      # @example
      #   serialize("name", :asc)   #=> "name"
      #   serialize("name", :desc)  #=> "-name"
      def serialize(name, direction)
        case normalize_direction(direction)
        when :asc then name.to_s
        when :desc then "-#{name}"
        end
      end

      def normalize_direction(direction)
        normalized = direction.to_sym if direction.respond_to?(:to_sym)
        return normalized if %i[asc desc].include?(normalized)

        raise ArgumentError, 'direction must be :asc or :desc'
      end
    end
  end
end
