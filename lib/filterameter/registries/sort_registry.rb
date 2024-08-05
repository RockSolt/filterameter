# frozen_string_literal: true

module Filterameter
  module Registries
    # # Sort Registry
    #
    # Class SortRegistry is a collection of the sorts. It captures the declarations when classes are loaded,
    # then uses the injected SortFactory to build the sorts on demand as they are needed.
    class SortRegistry < SubRegistry
      def sort_parameter_names
        @declarations.keys
      end

      private

      def build_declaration(name, options)
        Filterameter::SortDeclaration.new(name, options)
      end
    end
  end
end
