# frozen_string_literal: true

module Filterameter
  module Registries
    # = Registry
    #
    # Class Registry records declarations and allows resulting filters and sorts to be fetched from sub-registries.
    class Registry
      delegate :filter_declarations, :ranges, to: :@filter_registry

      def initialize(model_class)
        @filter_registry = Filterameter::Registries::FilterRegistry.new(Filterameter::FilterFactory.new(model_class))
        @sort_registry = Filterameter::Registries::SortRegistry.new(Filterameter::SortFactory.new(model_class))
      end

      def add_filter(parameter_name, options)
        @filter_registry.add(parameter_name, options)
      end

      def fetch_filter(parameter_name)
        @filter_registry.fetch(parameter_name)
      end

      def add_sort(parameter_name, options)
        @sort_registry.add(parameter_name, options)
      end

      def fetch_sort(parameter_name)
        @sort_registry.fetch(parameter_name)
      end
    end
  end
end
