# frozen_string_literal: true

require 'filterameter/controller_filters'

module Filterameter
  # = Declarative Filters
  #
  # module DeclarativeFilters provides a controller DSL to declare filters along with any validations.
  module DeclarativeFilters
    extend ActiveSupport::Concern

    included do
      before_action :build_filtered_query, only: :index
    end

    class_methods do
      def filter_model(model_class, query_var_name = nil)
        controller_filters.model_class = model_class
        filter_query_var_name(query_var_name) if query_var_name.present?
      end

      def filter_query_var_name(query_variable_name)
        controller_filters.query_variable_name = query_variable_name
      end

      def filter(name, options = {})
        controller_filters.add_filter(name, options)
      end

      def filters(*names)
        names.each { |name| filter(name) }
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
