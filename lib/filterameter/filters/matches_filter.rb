# frozen_string_literal: true

module Filterameter
  module Filters
    # = Matches Filter
    #
    # Class MatchesFilter uses arel's `matches` to generate a LIKE query.
    class MatchesFilter
      def initialize(attribute_name, options)
        @attribute_name = attribute_name
        @prefix = options.match_anywhere? ? '%' : nil
        @suffix = options.match_anywhere? || options.match_from_start? ? '%' : nil
        @case_sensitive = options.case_sensitive?
      end

      def apply(query, value)
        arel = query.arel_table[@attribute_name].matches("#{@prefix}#{value}#{@suffix}", false, @case_sensitive)
        query.where(arel)
      end
    end
  end
end
