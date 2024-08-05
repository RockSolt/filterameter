# frozen_string_literal: true

module Filterameter
  module DeclarationErrors
    # # Cannot Be Inline Scope Error
    #
    # Error CannotBeInlineScopeError occurs when an inline scope has been used to define a filter that takes a
    # parameter. This is not valid for use as a Filterameter filter because an inline scope always has an arity of -1
    # meaning the factory cannot tell if it has an argument or not. As such, all inline scopes are assumed to not have
    # arguments and thus be conditional scopes.
    #
    # [The Rails guide](https://guides.rubyonrails.org/active_record_querying.html#passing-in-arguments) provides
    # guidance suggesting scopes that take arguments be written as class methods. This takes that guidance a step
    # further and makes it a requirement for a scope that will be used as a filter.
    class CannotBeInlineScopeError < DeclarationError
      def initialize(model_name, scope_name)
        super(<<~ERROR.chomp)
          #{model_name} scope '#{scope_name}' needs to be written as a class method, not as an inline scope. This is a
            suggestion from the Rails guide but a requirement in order to use a scope that has an argument as a filter.
        ERROR
      end
    end
  end
end
