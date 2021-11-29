# frozen_string_literal: true

require 'filterameter/coordinators/query_coordinator'
require 'filterameter/filterable'
require 'filterameter/query_builder'

module Filterameter
  # = Declarative Filters
  #
  # Mixin DeclarativeFilters is included to build query classes using the filter DSL.
  module DeclarativeFilters
    extend ActiveSupport::Concern
    include Filterameter::Filterable

    class_methods do
      delegate :build_query, to: :filter_coordinator

      def model(model_class)
        filter_coordinator.model_class = model_class
      end

      def default_query(query)
        filter_coordinator.default_query = query
      end

      def filter_coordinator
        @filter_coordinator ||= Filterameter::Coordinators::QueryCoordinator.new
      end
    end
  end
end
