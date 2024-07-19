# frozen_string_literal: true

module Filterameter
  module Sorts
    # = Scope Sort
    #
    # Class ScopeSort applies the scope with the a param that is either :asc or :desc. A scope that does not take
    # exactly one argument is not valid for sorting.
    class ScopeSort < Filterameter::Filters::ScopeFilter
      private

      def validate(model)
        validate_is_a_scope(model)
      rescue ArgumentError
        @errors << "#{model.name} scope '#{@scope_name}' must take exactly one argument to sort by"
      end

      def validate_is_a_scope(model)
        return if model.public_send(@scope_name, :asc).is_a? ActiveRecord::Relation

        @errors << "#{model.name} class method '#{@scope_name}' is not a scope"
      end
    end
  end
end
