# frozen_string_literal: true

module Filterameter
  module Filters
    # = Scope Filter
    #
    # Class ScopeFilter applies the named scope passing in the parameter value.
    class ScopeFilter
      def initialize(scope_name)
        @scope_name = scope_name
      end

      def apply(query, value)
        query.public_send(@scope_name, value)
      end
    end
  end
end
