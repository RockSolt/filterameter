# frozen_string_literal: true

module Filterameter
  # # Query Builder
  #
  # Class Query Builder turns filter parameters into a query.
  #
  # The query builder is instantiated by the filter coordinator. The default query currently is simple `all`. The
  # default sort comes for the controller declaration of the same name; it is optional and the value may be nil.
  #
  # If the request includes a sort, it is always applied. If not, the following
  # logic kicks in to provide a sort:
  # *   if the starting query includes a sort, no additional sort is applied
  # *   if a default sort has been declared, it is applied
  # *   if neither of those provides a sort, then the fallback is primary key desc
  class QueryBuilder
    def initialize(default_query, default_sort, filter_registry)
      @default_query = default_query
      @default_sort = default_sort
      @registry = filter_registry
    end

    def build_query(filter_params, starting_query = nil)
      sorts, filters = parse_filter_params(filter_params.stringify_keys)
      query = apply_filters(starting_query || @default_query, filters)
      apply_sorts(query, sorts)
    end

    private

    def parse_filter_params(filter_params)
      sort = parse_sorts(filter_params.delete('sort'))
      [sort, remove_invalid_values(filter_params)]
    end

    def parse_sorts(sorts)
      Array.wrap(sorts).map { |sort| Helpers::RequestedSort.parse(sort) }
    end

    def apply_filters(query, filters)
      filters.tap { |parameters| convert_min_and_max_to_range(parameters) }
             .reduce(query) do |memo, (name, value)|
        add_filter_parameter_to_query(memo, name, value)
      end
    end

    def add_filter_parameter_to_query(query, filter_name, parameter_value)
      @registry.fetch_filter(filter_name).apply(query, parameter_value)
    rescue Filterameter::Exceptions::FilterameterError => e
      handle_undeclared_parameter(e)
      query
    end

    def apply_sorts(query, requested_sorts)
      return query if no_sort_requested_but_starting_query_includes_sort?(query, requested_sorts)

      sorts = requested_sorts.presence || @default_sort
      if sorts.present?
        sorts.reduce(query) { |memo, sort| add_sort_to_query(memo, sort.name, sort.direction) }
      else
        sort_by_primary_key_desc(query)
      end
    end

    def no_sort_requested_but_starting_query_includes_sort?(query, requested_sorts)
      requested_sorts.empty? && query.order_values.present?
    end

    def add_sort_to_query(query, name, direction)
      @registry.fetch_sort(name).apply(query, direction)
    rescue Filterameter::Exceptions::FilterameterError => e
      handle_undeclared_parameter(e)
      query
    end

    def sort_by_primary_key_desc(query)
      primary_key = query.model.primary_key
      query.order(primary_key => :desc)
    end

    # if both min and max are present in the query parameters, replace with range
    def convert_min_and_max_to_range(parameters)
      @registry.ranges.each do |attribute_name, min_max_names|
        next unless min_max_names.values.all? { |min_max_name| parameters[min_max_name].present? }

        parameters[attribute_name] = Range.new(parameters.delete(min_max_names[:min]),
                                               parameters.delete(min_max_names[:max]))
      end
    end

    # TODO: this handles any runtime exceptions, not just undeclared parameter
    # errors:
    # *   should the config option be more generalized?
    # *   or should there be a config option for each type of error?
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
