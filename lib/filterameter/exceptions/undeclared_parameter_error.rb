# frozen_string_literal: true

module Filterameter
  module Exceptions
    # = Undeclared Parameter Error
    #
    # Class UndeclaredParameterError is raised when a request contains filter parameters that have not been declared.
    # Configuration setting `action_on_undeclared_parameters` determines whether or not the exception is raised.
    class UndeclaredParameterError < FilterameterError
      attr_reader :keys

      def initialize(keys)
        super
        @keys = keys
      end

      def message
        "The following filter parameter(s) have not been declared: #{keys}"
      end
    end
  end
end
