# frozen_string_literal: true

module Filterameter
  module DeclarationErrors
    # # Not A Scope Error
    #
    # Error NotAScopeError flags a class method that has been used as a filter but is not a scope. This could occur if
    # there is a class method of the same name an attribute, in which case the class method is going to block the
    # creation of an attribute filter. The work around (if the class method cannot be renamed) is to create a scope
    # that provides a filter on the attribute.
    class NotAScopeError < DeclarationError
      def initialize(model_name, scope_name)
        super("#{model_name} class method '#{scope_name}' is not a scope.")
      end
    end
  end
end
