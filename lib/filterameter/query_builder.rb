# frozen_string_literal: true

module Filterameter
  # = Query Builder
  #
  # Class Query Builder turns filter parameters into a query.
  class QueryBuilder
    def initialize(default_query, filter_registry)
      @default_query = default_query
      @registry = filter_registry
    end

    def build_query(filter_params, starting_query)
      valid_filters(filter_params)
        .tap { |parameters| convert_min_and_max_to_range(parameters) }
        .reduce(starting_query || @default_query) do |query, (name, value)|
        @registry.fetch(name).apply(query, value)
      end
    end

    private

    def valid_filters(filter_params)
      remove_invalid_values(
        remove_undeclared_filters(filter_params)
      )
    end

    # if both min and max are present in the query parameters, replace with range
    def convert_min_and_max_to_range(parameters)
      @registry.ranges.each do |attribute_name, min_max_names|
        next unless min_max_names.values.all? { |min_max_name| parameters[min_max_name].present? }

        parameters[attribute_name] = Range.new(parameters.delete(min_max_names[:min]),
                                               parameters.delete(min_max_names[:max]))
      end
    end

    def remove_undeclared_filters(filter_params)
      filter_params.slice(*declared_parameter_names).tap do |declared_parameters|
        handle_undeclared_parameters(filter_params) if declared_parameters.size != filter_params.size
      end
    end

    def handle_undeclared_parameters(filter_params)
      action = Filterameter.configuration.action_on_undeclared_parameters
      return unless action

      undeclared_parameter_names = filter_params.keys - declared_parameter_names
      case action
      when :log
        ActiveSupport::Notifications.instrument('undeclared_parameters.filterameter', keys: undeclared_parameter_names)
      when :raise
        raise Filterameter::Exceptions::UndeclaredParameterError, undeclared_parameter_names
      end
    end

    def remove_invalid_values(filter_params)
      validator = validator_class.new(filter_params)
      return filter_params if validator.valid?

      case Filterameter.configuration.action_on_validation_failure
      when :log
        ActiveSupport::Notifications.instrument('validation_failure.filterameter', errors: validator.errors)
      when :raise
        raise Filterameter::Exceptions::ValidationError, validator.errors
      end

      filter_params.except(*validator.errors.keys.map(&:to_s))
    end

    def declared_parameter_names
      @registry.filter_names
    end

    def validator_class
      @validator_class ||= Filterameter::ParametersBase.build_sub_class(@registry.filter_declarations)
    end
  end
end
