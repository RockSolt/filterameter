# frozen_string_literal: true

module Filterameter
  module Filters
    # # Conditional Scope Filter
    #
    # Class ConditionalScopeFilter applies the scope if the parameter is not false.
    class ConditionalScopeFilter
      include Filterameter::Errors

      def initialize(scope_name)
        @scope_name = scope_name
      end

      def apply(query, value)
        return query unless ActiveModel::Type::Boolean.new.cast(value)

        query.public_send(@scope_name)
      end

      private

      def validate(model)
        validate_is_a_scope(model)
      rescue ArgumentError
        @errors << Filterameter::DeclarationErrors::CannotBeInlineScopeError.new(model.name, @scope_name)
      end

      def validate_is_a_scope(model)
        return if model.public_send(@scope_name).is_a? ActiveRecord::Relation

        @errors << Filterameter::DeclarationErrors::NotAScopeError.new(model.name, @scope_name)
      end
    end
  end
end
