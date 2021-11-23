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
require 'filterameter/query_builder'

module Filterameter
  # = Controller Filters
  #
  # Class ControllerFilters stores the configuration declared via class-level method calls such as the list of
  # filters and the optionally declared model class. Each controller will have one instance of the controller
  # declarations stored as a class variable.
  class ControllerFilters
    attr_writer :query_variable_name

    delegate :add_filter, to: :registry
    delegate :build_query, to: :query_builder

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

    def query_builder
      @query_builder ||= Filterameter::QueryBuilder.new(model_class.all, registry)
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
  end
end
