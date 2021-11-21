# frozen_string_literal: true

require 'filterameter/declarative_filters'
require 'filterameter/controller_filters'

module Filterameter
  # = Declarative Controller Filters
  #
  # Mixin DeclarativeControllerFilters can included in controllers to enable the filter DSL.
  module DeclarativeControllerFilters
    extend ActiveSupport::Concern
    include Filterameter::DeclarativeFilters

    class_methods do
      def filter_model(model_class, query_var_name = nil)
        controller_filters.model_class = model_class
        filter_query_var_name(query_var_name) if query_var_name.present?
      end

      def filter_query_var_name(query_variable_name)
        controller_filters.query_variable_name = query_variable_name
      end

      def controller_filters
        @controller_filters ||= Filterameter::ControllerFilters.new(controller_name, controller_path)
      end
    end

    private

    def build_filtered_query
      var_name = "@#{self.class.controller_filters.query_variable_name}"
      instance_variable_set(
        var_name,
        self.class.controller_filters.build_query(params.to_unsafe_h.fetch(:filter, {}),
                                                  instance_variable_get(var_name))
      )
    end
  end
end
