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

    def build_query(filter_params, starting_query = nil)
      valid_filters(filter_params.stringify_keys)
        .tap { |parameters| convert_min_and_max_to_range(parameters) }
        .reduce(starting_query || @default_query) do |query, (name, value)|
        add_filter_parameter_to_query(query, name, value)
      end
    end

    private

    def add_filter_parameter_to_query(query, filter_name, parameter_value)
      @registry.fetch(filter_name).apply(query, parameter_value)
    rescue Filterameter::Exceptions::UndeclaredParameterError => e
      handle_undeclared_parameter(e)
      query
    end

    def valid_filters(filter_params)
      remove_invalid_values(filter_params)
    end

    # if both min and max are present in the query parameters, replace with range
    def convert_min_and_max_to_range(parameters)
      @registry.ranges.each do |attribute_name, min_max_names|
        next unless min_max_names.values.all? { |min_max_name| parameters[min_max_name].present? }

        parameters[attribute_name] = Range.new(parameters.delete(min_max_names[:min]),
                                               parameters.delete(min_max_names[:max]))
      end
    end

    def handle_undeclared_parameter(exception)
      action = Filterameter.configuration.action_on_undeclared_parameters
      return unless action

      case action
      when :log
        ActiveSupport::Notifications.instrument('undeclared_parameters.filterameter', key: exception.key)
      when :raise
        raise exception
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

      filter_params.except(*validator.errors.attribute_names.map(&:to_s))
    end

    def validator_class
      @validator_class ||= Filterameter::ParametersBase.build_sub_class(@registry.filter_declarations)
    end
  end
end
