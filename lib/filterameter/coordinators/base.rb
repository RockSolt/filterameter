# frozen_string_literal: true

require 'filterameter/filter_declaration'
require 'filterameter/filter_factory'
require 'filterameter/filter_registry'
require 'filterameter/log_subscriber'
require 'filterameter/parameters_base'
require 'filterameter/query_builder'

module Filterameter
  module Coordinators
    # = Coordinators Base
    #
    # The main responsibility of the Coordinators classes is to keep the namespace clean for controllers and query
    # objects that implement filter parameters. The coordinators encapsulate references to the Query Builder and
    # Filter Registry.
    class Base
      attr_reader :model_class

      delegate :add_filter, to: :registry
      delegate :build_query, to: :query_builder

      def model_class=(model_class)
        @model_class = model_class.is_a?(String) ? model_class.constantize : model_class
      end

      def query_builder
        @query_builder ||= Filterameter::QueryBuilder.new(model_class.all, registry)
      end

      private

      # lazy so that model_class can be optionally set
      def registry
        @registry ||= Filterameter::FilterRegistry.new(Filterameter::FilterFactory.new(model_class))
      end
    end
  end
end
