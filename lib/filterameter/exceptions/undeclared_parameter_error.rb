# frozen_string_literal: true

module Filterameter
  module Exceptions
    # = Undeclared Parameter Error
    #
    # Class UndeclaredParameterError is raised when a request contains filter parameters that have not been declared.
    # Configuration setting `action_on_undeclared_parameters` determines whether or not the exception is raised.
    class UndeclaredParameterError < FilterameterError
      attr_reader :key

      def initialize(key)
        super
        @key = key
      end

      def message
        "The following filter parameter has not been declared: #{key}"
      end
    end
  end
end
