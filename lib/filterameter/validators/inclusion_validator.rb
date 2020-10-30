# frozen_string_literal: true

module Filterameter
  module Validators
    # = Inclusion Validator
    #
    # Class InclusionValidator extends ActiveModel::Validations::InclusionValidator to enable validations of multiple
    # values.
    #
    # == Example
    #
    #   validates: { inclusion: { in: %w[Small Medium Large], allow_multiple_values: true } }
    #
    class InclusionValidator < ActiveModel::Validations::InclusionValidator
      def validate_each(record, attribute, value)
        return super unless allow_multiple_values?

        # any? just provides a mechanism to stop after first error
        Array.wrap(value).any? { |v| super(record, attribute, v) }
      end

      private

      def allow_multiple_values?
        @options.fetch(:allow_multiple_values, false)
      end
    end
  end
end
