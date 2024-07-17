# frozen_string_literal: true

module Filterameter
  # = Filter Factory
  #
  # Class FilterFactory builds a filter from a FilterDeclaration.
  class FilterFactory
    def initialize(model_class)
      @model_class = model_class
    end

    def build(declaration)
      context = Helpers::DeclarationWithModel.new(@model_class, declaration)

      if declaration.nested?
        build_nested_filter(declaration, context)
      else
        build_filter(@model_class, declaration, context.scope?)
      end
    end

    private

    def build_nested_filter(declaration, context)
      model = context.model_from_association
      filter = build_filter(model, declaration, context.scope?)
      nested_filter_class = context.any_collections? ? Filters::NestedCollectionFilter : Filters::NestedFilter

      nested_filter_class.new(declaration.association, model, filter)
    end

    def build_filter(model, declaration, declaration_is_a_scope) # rubocop:disable Metrics/MethodLength
      if declaration_is_a_scope
        build_scope_filter(model, declaration)
      elsif declaration.partial_search?
        Filterameter::Filters::MatchesFilter.new(declaration.name, declaration.partial_options)
      elsif declaration.minimum_range?
        Filterameter::Filters::MinimumFilter.new(model, declaration.name)
      elsif declaration.maximum_range?
        Filterameter::Filters::MaximumFilter.new(model, declaration.name)
      else
        Filterameter::Filters::AttributeFilter.new(declaration.name)
      end
    end

    # Inline scopes return an arity of -1 regardless of arguments, so those will always be assumed to be
    # conditional scopes. To have a filter that passes a value to a scope, it must be a class method.
    def build_scope_filter(model, declaration)
      if model.method(declaration.name).arity == -1
        Filterameter::Filters::ConditionalScopeFilter.new(declaration.name)
      else
        Filterameter::Filters::ScopeFilter.new(declaration.name)
      end
    end
  end
end
