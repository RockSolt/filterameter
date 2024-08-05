# frozen_string_literal: true

module Filterameter
  module Helpers
    # # Reqested Sort
    #
    # Class RequestedSort parses the name and direction from a sort segment.
    class RequestedSort
      SIGN_AND_NAME = /(?<sign>[+|-]?)(?<name>\w+)/
      attr_reader :name, :direction

      def self.parse(sort)
        parsed = sort.match SIGN_AND_NAME

        new(parsed['name'],
            parsed['sign'] == '-' ? :desc : :asc)
      end

      def initialize(name, direction)
        @name = name
        @direction = direction
      end
    end
  end
end
