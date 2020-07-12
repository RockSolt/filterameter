# frozen_string_literal: true

require 'active_support/inflector'

require 'active_support/rails'
require 'action_dispatch'
require 'action_controller/metal/live'
require 'action_controller/metal/strong_parameters'

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

    def initialize(controller_name, controller_path)
      @controller_name = controller_name
      @controller_path = controller_path
      @declarations = {}
      @ranges = {}
      @filters = Hash.new { |hash, key| hash[key] = filter_factory.build(@declarations[key]) }
    end

    def model_class=(model_class)
      @model_class = model_class.is_a?(String) ? model_class.constantize : model_class
    end

    def add_filter(parameter_name, options)
      @declarations[parameter_name.to_s] =
        Filterameter::FilterDeclaration.new(parameter_name, options).tap do |fd|
          add_declarations_for_range(fd, options, parameter_name) if fd.range_enabled?
        end
    end

    def query_variable_name
      @query_variable_name ||= model_class.model_name.plural
    end

    def build_query(filter_params, starting_query)
      valid_filters(filter_params)
        .tap { |parameters| convert_min_and_max_to_range(parameters) }
        .reduce(starting_query || model_class.all) do |query, (name, value)|
        @filters[name].apply(query, value)
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
    def filter_factory
      @filter_factory ||= Filterameter::FilterFactory.new(model_class)
    end

    def valid_filters(filter_params)
      remove_invalid_values(
        remove_undeclared_filters(filter_params)
      )
    end

    # if both min and max are present in the query parameters, replace with range
    def convert_min_and_max_to_range(parameters)
      @ranges.each do |attribute_name, min_max_names|
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
      @declared_parameter_names ||= @declarations.keys
    end

    def validator_class
      @validator_class ||= Filterameter::ParametersBase.build_sub_class(@declarations.values)
    end

    # if range is enabled, then in addition to the attribute filter this also adds min and/or max filters
    def add_declarations_for_range(attribute_declaration, options, parameter_name)
      add_range_minimum(parameter_name, options) if attribute_declaration.range? || attribute_declaration.minimum?
      add_range_maximum(parameter_name, options) if attribute_declaration.range? || attribute_declaration.maximum?
      capture_range_declaration(parameter_name) if attribute_declaration.range?
    end

    def add_range_minimum(parameter_name, options)
      @declarations["#{parameter_name}_min"] = Filterameter::FilterDeclaration.new(parameter_name,
                                                                                   options.merge(range: :min_only))
    end

    def add_range_maximum(parameter_name, options)
      @declarations["#{parameter_name}_max"] = Filterameter::FilterDeclaration.new(parameter_name,
                                                                                   options.merge(range: :max_only))
    end

    # memoizing these makes it easier to spot and replace ranges in query parameters; see convert_min_and_max_to_range
    def capture_range_declaration(name)
      @ranges[name] = { min: "#{name}_min", max: "#{name}_max" }
    end
  end
end
