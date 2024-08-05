# frozen_string_literal: true

module Filterameter
  module DeclarationErrors
    # # Sort Scope Requires One Argument Error
    #
    # Error SortScopeRequiresOneArgumentError occurs when a sort has been declared for a scope that does not take
    # exactly one argument. Sort scopes must take a single argument and will receive either :asc or :desc to indicate
    # the direction.
    class SortScopeRequiresOneArgumentError < DeclarationError
      def initialize(model_name, scope_name)
        super("#{model_name} scope '#{scope_name}' must take exactly one argument to sort by.")
      end
    end
  end
end
