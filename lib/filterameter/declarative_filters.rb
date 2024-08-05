# frozen_string_literal: true

module Filterameter
  # # Declarative Controller Filters
  #
  # Mixin DeclarativeFilters should be included in controllers to enable the filter DSL.
  module DeclarativeFilters
    extend ActiveSupport::Concern
    include Filterameter::Filterable
    include Filterameter::Sortable

    class_methods do
      delegate :declarations_validator, to: :filter_coordinator

      def filter_model(model_class, query_var_name = nil)
        filter_coordinator.model_class = model_class
        filter_query_var_name(query_var_name) if query_var_name.present?
      end

      def filter_query_var_name(query_variable_name)
        filter_coordinator.query_variable_name = query_variable_name
      end

      def filter_coordinator
        @filter_coordinator ||= Filterameter::FilterCoordinator.new(controller_name, controller_path)
      end
    end

    # Returns an ActiveRecord query from the filter parameters.
    #
    #     def index
    #       @widgets = build_query_from_filters
    #     end
    #
    # The method optionally takes a starting query. For example, this restricts the results
    # to only active widgets:
    #
    #     def index
    #       @widgets = build_query_from_filters(Widgets.where(active: true))
    #     end
    #
    # The starting query can also be used to provide eager loading:
    #
    #     def index
    #       @widgets = build_query_from_filters(Widgets.includes(:manufacturer))
    #     end
    def build_query_from_filters(starting_query = nil)
      self.class.filter_coordinator.build_query(filter_parameters, starting_query)
    end

    def filter_parameters
      filter_key = Filterameter.configuration.filter_key

      if filter_key
        params.to_unsafe_h.fetch(filter_key, {})
      else
        params.to_unsafe_h.slice(*self.class.filter_coordinator.filter_parameter_names, :sort)
      end
    end

    private

    def build_filtered_query
      var_name = "@#{self.class.filter_coordinator.query_variable_name}"
      starting_query = instance_variable_get(var_name)
      instance_variable_set(var_name, build_query_from_filters(starting_query))
    end
  end
end
