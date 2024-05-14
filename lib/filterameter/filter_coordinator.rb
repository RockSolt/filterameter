# frozen_string_literal: true

require 'active_support/inflector'

require 'active_support/rails'
require 'action_dispatch'
require 'action_controller/metal/live'
require 'action_controller/metal/strong_parameters'

module Filterameter
  # = Filter Coordinator
  #
  # Class FilterCoordinator stores the configuration declared via class-level method calls such as the list of
  # filters and the optionally declared model class. Each controller will have one instance of the coordinator
  # stored as a class variable.
  #
  # The coordinators encapsulate references to the Query Builder and Filter Registry to keep the namespace clean for
  # controllers that implement filter parameters.
  class FilterCoordinator
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

    def query_builder
      @query_builder ||= Filterameter::QueryBuilder.new(default_query, registry)
    end

    def query_variable_name
      @query_variable_name ||= model_class.model_name.plural
    end

    private

    def model_class
      @model_class ||= @controller_name.classify.safe_constantize ||
                       @controller_path.classify.safe_constantize ||
                       raise(Filterameter::Exceptions::CannotDetermineModelError.new(@controller_name,
                                                                                     @controller_path))
    end

    def default_query
      model_class.all
    end

    # lazy so that model_class can be optionally set
    def registry
      @registry ||= Filterameter::FilterRegistry.new(Filterameter::FilterFactory.new(model_class))
    end
  end
end
