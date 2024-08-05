# frozen_string_literal: true

module Filterameter
  # # Sort Factory
  #
  # Class SortFactory builds a sort from a model and a declaration.
  class SortFactory
    def initialize(model_class)
      @model_class = model_class
    end

    def build(declaration)
      context = Helpers::DeclarationWithModel.new(@model_class, declaration)

      if declaration.nested?
        build_nested_sort(declaration, context)
      else
        build_sort(declaration.name, context.scope?)
      end
    end

    private

    def build_nested_sort(declaration, context)
      validate!(declaration, context)

      model = context.model_from_association
      sort = build_sort(declaration.name, context.scope?)
      nested_sort_class = context.any_collections? ? Filters::NestedCollectionFilter : Filters::NestedFilter

      nested_sort_class.new(declaration.association, model, sort)
    end

    def build_sort(name, declaration_is_a_scope)
      if declaration_is_a_scope
        Filterameter::Sorts::ScopeSort.new(name)
      else
        Filterameter::Sorts::AttributeSort.new(name)
      end
    end

    def validate!(declaration, context)
      return unless context.any_collections?

      raise Exceptions::CollectionAssociationSortError, declaration
    end
  end
end
