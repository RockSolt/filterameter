# frozen_string_literal: true

module Filterameter
  # = Declarative Controller Filters
  #
  # Mixin DeclarativeFilters can included in controllers to enable the filter DSL.
  module DeclarativeFilters
    extend ActiveSupport::Concern
    include Filterameter::Filterable

    class_methods do
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

    private

    def build_filtered_query
      var_name = "@#{self.class.filter_coordinator.query_variable_name}"
      instance_variable_set(
        var_name,
        self.class.filter_coordinator.build_query(params.to_unsafe_h.fetch(:filter, {}),
                                                  instance_variable_get(var_name))
      )
    end
  end
end
