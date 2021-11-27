# frozen_string_literal: true

require 'active_support/inflector'

require 'active_support/rails'
require 'action_dispatch'
require 'action_controller/metal/live'
require 'action_controller/metal/strong_parameters'

require 'filterameter/coordinators/base'

module Filterameter
  module Coordinators
    # = Controller Filters
    #
    # Class ControllerFilters stores the configuration declared via class-level method calls such as the list of
    # filters and the optionally declared model class. Each controller will have one instance of the controller
    # declarations stored as a class variable.
    class ControllerCoordinator < Filterameter::Coordinators::Base
      attr_writer :query_variable_name

      def initialize(controller_name, controller_path)
        @controller_name = controller_name
        @controller_path = controller_path
        super()
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
    end
  end
end
