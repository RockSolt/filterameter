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
      if declaration.nested?
        build_nested_filter(declaration)
      else
        build_filter(@model_class, declaration)
      end
    end

    private

    def build_nested_filter(declaration)
      model = model_from_association(declaration.association)
      filter = build_filter(model, declaration)
      clazz = filter_class(declaration.association)

      clazz.new(declaration.association, model, filter)
    end

    def build_filter(model, declaration) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # checking dangerous_class_method? excludes any names that cannot be scope names, such as "name"
      if model.respond_to?(declaration.name) && !model.dangerous_class_method?(declaration.name)
        build_scope_filter(model, declaration)
      elsif declaration.partial_search?
        Filterameter::Filters::MatchesFilter.new(declaration.name, declaration.partial_options)
      elsif declaration.minimum?
        Filterameter::Filters::MinimumFilter.new(model, declaration.name)
      elsif declaration.maximum?
        Filterameter::Filters::MaximumFilter.new(model, declaration.name)
      else
        Filterameter::Filters::AttributeFilter.new(declaration.name)
      end
    end

    # Inline scopes return an arity of -1 regardless of arguments, so those will always be assumed to be
    # conditional scopes. To have a filter that passes a value to a scope, it must be a class method.
    def build_scope_filter(model, declaration)
      if model.method(declaration.name).arity == 1
        Filterameter::Filters::ScopeFilter.new(declaration.name)
      else
        Filterameter::Filters::ConditionalScopeFilter.new(declaration.name)
      end
    end

    def filter_class(association_names)
      if any_collections?(association_names)
        Filters::NestedCollectionFilter
      else
        Filters::NestedFilter
      end
    end

    def any_collections?(association_names)
      association_names.reduce(@model_class) do |model, name|
        association = model.reflect_on_association(name)
        return true if association.collection?

        association.klass
      end

      false
    end

    # TODO: rescue then raise custom error with cause
    def model_from_association(association)
      association.flatten.reduce(@model_class) { |memo, name| memo.reflect_on_association(name).klass }
      # rescue StandardError => e
    end
  end
end
