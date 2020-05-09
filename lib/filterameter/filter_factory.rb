# frozen_string_literal: true

require 'filterameter/filters/attribute_filter'
require 'filterameter/filters/conditional_scope_filter'
require 'filterameter/filters/matches_filter'
require 'filterameter/filters/nested_filter'
require 'filterameter/filters/scope_filter'

module Filterameter
  # = Filter Factory
  #
  # Class FilterFactory builds a filter from a FilterDeclaration.
  class FilterFactory
    def initialize(model_class)
      @model_class = model_class
    end

    def build(declaration)
      model = declaration.nested? ? model_from_association(declaration.association) : @model_class
      filter = build_filter(model, declaration)

      declaration.nested? ? Filterameter::Filters::NestedFilter.new(declaration.association, model, filter) : filter
    end

    private

    def build_filter(model, declaration)
      # checking dangerous_class_method? excludes any names that cannot be scope names, such as "name"
      if model.respond_to?(declaration.name) && !model.dangerous_class_method?(declaration.name)
        Filterameter::Filters::ScopeFilter.new(declaration.name)
      elsif declaration.partial_search?
        Filterameter::Filters::MatchesFilter.new(declaration.name, declaration.partial_options)
      else
        Filterameter::Filters::AttributeFilter.new(declaration.name)
      end
    end

    # TODO: rescue then raise custom error with cause
    def model_from_association(association)
      [association].flatten.reduce(@model_class) { |memo, name| memo.reflect_on_association(name).klass }
      # rescue StandardError => e
    end
  end
end
