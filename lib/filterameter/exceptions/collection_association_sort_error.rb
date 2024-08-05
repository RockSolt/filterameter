# frozen_string_literal: true

module Filterameter
  module Exceptions
    # # Collection Association Sort Error
    #
    # Class CollectionAssociationSortError is raised when a sort is attempted on a
    # collection association. (Sorting is only valid on *singular* associations.)
    class CollectionAssociationSortError < FilterameterError
      def initialize(declaration)
        super("Sorting is not allowed on collection associations: \n\t\t#{declaration}")
      end
    end
  end
end
