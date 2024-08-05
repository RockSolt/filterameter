# frozen_string_literal: true

module Filterameter
  module Filters
    # # Scope Filter
    #
    # Class ScopeFilter applies the named scope passing in the parameter value.
    class ScopeFilter
      include Filterameter::Errors

      def initialize(scope_name)
        @scope_name = scope_name
      end

      def apply(query, value)
        query.public_send(@scope_name, value)
      end

      private

      def validate(model)
        validate_is_a_scope(model)
      end

      def validate_is_a_scope(model)
        return if model.public_send(@scope_name, '42').is_a? ActiveRecord::Relation

        @errors << Filterameter::DeclarationErrors::NotAScopeError.new(model.name, @scope_name)
      end
    end
  end
end
