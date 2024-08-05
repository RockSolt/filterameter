# frozen_string_literal: true

module Filterameter
  module Exceptions
    # # Invalid Association Declaration Error
    #
    # Class InvalidAssociationDeclarationError is raised when the declared association(s) are not valid.
    class InvalidAssociationDeclarationError < FilterameterError
      def initialize(name, model_name, associations)
        super("The association(s) declared on filter #{name} are not valid for model #{model_name}: #{associations}")
      end
    end
  end
end
