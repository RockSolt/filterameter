# frozen_string_literal: true

require 'active_support/inflector'

require 'active_support/rails'
require 'action_dispatch'
require 'action_controller/metal/live'
require 'action_controller/metal/strong_parameters'

require 'filterameter/filter_registry'
require 'filterameter/filter_factory'
require 'filterameter/filter_declaration'
require 'filterameter/log_subscriber'
require 'filterameter/parameters_base'

module Filterameter
  # = Controller Filters
  #
  # Class ControllerFilters stores the configuration declared via class-level method calls such as the list of
  # filters and the optionally declared model class. Each controller will have one instance of the controller
  # declarations stored as a class variable.
  class ControllerFilters
    attr_writer :query_variable_name

    delegate :add_filter, to: :registry

    def initialize(controller_name, controller_path)
      @controller_name = controller_name
      @controller_path = controller_path
    end

    def model_class=(model_class)
      @model_class = model_class.is_a?(String) ? model_class.constantize : model_class
    end

    def query_variable_name
      @query_variable_name ||= model_class.model_name.plural
    end

    def build_query(filter_params, starting_query)
      valid_filters(filter_params)
        .tap { |parameters| convert_min_and_max_to_range(parameters) }
        .reduce(starting_query || model_class.all) do |query, (name, value)|
        registry.fetch(name).apply(query, value)
      end
    end

    private

    def model_class
      @model_class ||= @controller_name.classify.safe_constantize ||
                       @controller_path.classify.safe_constantize ||
                       raise(Filterameter::Exceptions::CannotDetermineModelError.new(@controller_name,
                                                                                     @controller_path))
    end

    # lazy so that model_class can be optionally set
    def registry
      @registry ||= Filterameter::FilterRegistry.new(Filterameter::FilterFactory.new(model_class))
    end

    def valid_filters(filter_params)
      remove_invalid_values(
        remove_undeclared_filters(filter_params)
      )
    end

    # if both min and max are present in the query parameters, replace with range
    def convert_min_and_max_to_range(parameters)
      registry.ranges.each do |attribute_name, min_max_names|
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
      registry.filter_names
    end

    def validator_class
      @validator_class ||= Filterameter::ParametersBase.build_sub_class(registry.filter_declarations)
    end
  end
end
