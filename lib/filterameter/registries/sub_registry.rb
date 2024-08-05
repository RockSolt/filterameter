# frozen_string_literal: true

module Filterameter
  module Registries
    # # SubRegistry
    #
    # Class SubRegistry provides add and fetch methods as well as the initialization for sub-registries.
    #
    # Subclasses must implement build_declaration.
    class SubRegistry
      def initialize(factory)
        @factory = factory
        @declarations = {}
        @registry = {}
      end

      def add(parameter_name, options)
        name = parameter_name.to_s
        @declarations[name] = build_declaration(name, options)
      end

      def fetch(parameter_name)
        name = parameter_name.to_s
        @registry.fetch(name) do
          raise Filterameter::Exceptions::UndeclaredParameterError, name unless @declarations.keys.include?(name)

          @registry[name] = @factory.build(@declarations[name])
        end
      end

      def parameter_names
        @declarations.keys
      end
    end
  end
end
