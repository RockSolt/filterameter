# frozen_string_literal: true

module Filterameter
  module Filters
    # = Conditional Scope Filter
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
        @errors << "#{model.name} scope '#{@scope_name}' needs to be written as a class method, not as an inline scope"
      end

      def validate_is_a_scope(model)
        return if model.public_send(@scope_name).is_a? ActiveRecord::Relation

        @errors << "#{model.name} class method '#{@scope_name}' is not a scope"
      end
    end
  end
end
