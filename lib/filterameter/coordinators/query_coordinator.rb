# frozen_string_literal: true

module Filterameter
  module Coordinators
    # = Query Coordinator
    #
    # Class QueryCoordinator coordinates the filter logic for query classes.
    class QueryCoordinator < Filterameter::Coordinators::Base
      attr_writer :default_query

      private

      def default_query
        @default_query || super
      end
    end
  end
end
