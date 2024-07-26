# frozen_string_literal: true

module Filterameter
  module DeclarationErrors
    # = No Such Attribute Error
    #
    # Error NoSuchAttributeError occurs when a filter or sort references an attribute that does not exist on the model.
    # The most likely case of this is a typo. Note that if the typo was supposed to reference a scope, this error is
    # added as attributes are assumed when no matching scopes are found.
    class NoSuchAttributeError < DeclarationError
      def initialize(model_name, attribute_name)
        super("Attribute '#{attribute_name}' does not exist on #{model_name}")
      end
    end
  end
end
