# frozen_string_literal: true

module Filterameter
  module DeclarationErrors
    # # Unexpected Error
    #
    # Error UnexpectedError occurs when the filter or scope factory raises an exception that the validator did not
    # expect.
    class UnexpectedError < DeclarationError
      def initialize(error)
        super(<<~ERROR)
          The previous error was unexpected. It occurred during while building a filter or sort (see below). Please
          report this to the library so that the error can be handled and provide clearer feedback about what is wrong
          with the declaration.

          #{error.message}
            #{error.backtrace.join("\n\t")}
        ERROR
      end
    end
  end
end
