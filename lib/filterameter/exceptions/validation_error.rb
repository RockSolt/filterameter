# frozen_string_literal: true

module Filterameter
  module Exceptions
    # = Validation Error
    #
    # Class ValidationError is raised when a specified parameter fails a validation. Configuration setting
    # `action_on_validation_failure` determines whether or not the exception is raised.
    class ValidationError < FilterameterError
      attr_reader :errors

      def initialize(errors)
        super
        @errors = errors
      end

      def message
        "The following parameter(s) failed validation: #{errors.full_messages}"
      end
    end
  end
end
