# frozen_string_literal: true

module Filterameter
  module Exceptions
    class FilterameterError < StandardError
    end
  end
end

require 'filterameter/exceptions/cannot_determine_model_error'
require 'filterameter/exceptions/validation_error'
require 'filterameter/exceptions/undeclared_parameter_error'
