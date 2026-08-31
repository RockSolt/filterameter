# frozen_string_literal: true

module Filterameter
  module SortStrategies
    # # Replacement Sort Strategy
    #
    # The ReplacementSortStrategy replaces the current sort with the requested sort. If the field is not currently being
    # sorted, it will be added in the initial direction.If the field is currently being sorted in the initial
    # sorted in the initial direction, the direction will be toggled; if the field is currently being sorted in the opposite direction, the
    # sort will be removed unless doing so would immediately restore the same default sort, in which case it returns to the
    # initial direction instead.
    class ReplacementSortStrategy
      def call(query_params, sort_field, initial_direction)
        return { sort_field => initial_direction } unless query_params.sorted_by?(sort_field)

        if query_params.sort_direction(sort_field) == initial_direction
          { sort_field => opposite_direction(initial_direction) }
        else
          return { sort_field => initial_direction } unless query_params.sort_requested?
          if query_params.requested_sort_order == query_params.default_sort_order
            return { sort_field => initial_direction }
          end

          {}
        end
      end

      private

      def opposite_direction(direction)
        direction == :asc ? :desc : :asc
      end
    end
  end
end
