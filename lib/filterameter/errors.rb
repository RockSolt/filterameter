# frozen_string_literal: true

module Filterameter
  # # Errors
  #
  # Module Errors provides `valid?` and `errors` to implementing classes. If the `valid?` method is not overridden,
  # then it returns true.
  #
  # To provide validations rules, override `validate`. If any fail, populate the errors attribute with the
  # reason for the failures.
  module Errors
    attr_reader :errors

    def valid?(model = nil)
      @errors = []
      validate(model)
      @errors.empty?
    end

    private

    def validate(_model); end
  end
end
