# frozen_string_literal: true

module Filterameter
  module Filters
    # = Conditional Scope Filter
    #
    # Class ConditionalScopeFilter applies the scope if the parameter is not false.
    class ConditionalScopeFilter
      def initialize(scope_name)
        @scope_name = scope_name
      end

      def apply(query, value)
        return query unless ActiveModel::Type::Boolean.new.cast(value)

        query.send(@scope_name)
      end
    end
  end
end
