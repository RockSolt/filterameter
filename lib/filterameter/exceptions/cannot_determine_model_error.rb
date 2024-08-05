# frozen_string_literal: true

module Filterameter
  module Exceptions
    # # Cannot Determine Model Error
    #
    # Class CannotDetermineModelError is raised when the model class cannot be determined from either the controller
    # name or controller path. This is a setup issue; the resolution is for the controller to specify the model class
    # explicitly by adding a call to `filter_model`.
    class CannotDetermineModelError < FilterameterError
      def initialize(name, path)
        super("Cannot determine model name from controller name #{value_and_classify(name)} " \
              "or path #{value_and_classify(path)}. Declare the model explicitly with filter_model.")
      end

      private

      def value_and_classify(value)
        "(#{value} => #{value.classify})"
      rescue StandardError
        value
      end
    end
  end
end
