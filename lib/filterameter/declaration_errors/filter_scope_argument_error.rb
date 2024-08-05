# frozen_string_literal: true

module Filterameter
  module DeclarationErrors
    # # Filter Scope Argument Error
    #
    # Error FilterScopeArgumentError occurs when a scope used as a filter but does not have either zero or one
    # arument. A conditional scope filter should take zero arguments; other scope filters should take one argument.
    class FilterScopeArgumentError < DeclarationError
      def initialize(model_name, scope_name)
        super("#{model_name} scope '#{scope_name}' takes too many arguments. Scopes for filters can only have either " \
              'zero (conditional scope) or one argument')
      end
    end
  end
end
