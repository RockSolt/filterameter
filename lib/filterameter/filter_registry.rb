# frozen_string_literal: true

module Filterameter
  # Filters
  #
  # Class FilterRegistry is a collection of the filters. It captures the filter declarations when classes are loaded,
  # then uses the injected FilterFactory to build the filters on demand as they are needed.
  class FilterRegistry
    attr_reader :ranges

    def initialize(filter_factory)
      @filter_factory = filter_factory
      @declarations = {}
      @ranges = {}
      @filters = {}
    end

    def add_filter(parameter_name, options)
      name = parameter_name.to_s
      @declarations[name] = Filterameter::FilterDeclaration.new(name, options).tap do |fd|
        add_declarations_for_range(fd, options, name) if fd.range_enabled?
      end
    end

    def fetch(parameter_name)
      name = parameter_name.to_s
      @filters.fetch(name) do
        raise Filterameter::Exceptions::UndeclaredParameterError, name unless @declarations.keys.include?(name)

        @filters[name] = @filter_factory.build(@declarations[name])
      end
    end

    def filter_declarations
      @declarations.values
    end

    private

    # if range is enabled, then in addition to the attribute filter this also adds min and/or max filters
    def add_declarations_for_range(attribute_declaration, options, parameter_name)
      add_range_minimum(parameter_name, options) if attribute_declaration.range? || attribute_declaration.min_only?
      add_range_maximum(parameter_name, options) if attribute_declaration.range? || attribute_declaration.max_only?
      capture_range_declaration(parameter_name) if attribute_declaration.range?
    end

    def add_range_minimum(parameter_name, options)
      parameter_name_min = "#{parameter_name}_min"
      options_with_name = options.with_defaults(name: parameter_name)
      @declarations[parameter_name_min] = Filterameter::FilterDeclaration.new(parameter_name_min,
                                                                              options_with_name,
                                                                              range_type: :minimum)
    end

    def add_range_maximum(parameter_name, options)
      parameter_name_max = "#{parameter_name}_max"
      options_with_name = options.with_defaults(name: parameter_name)
      @declarations[parameter_name_max] = Filterameter::FilterDeclaration.new(parameter_name_max,
                                                                              options_with_name,
                                                                              range_type: :maximum)
    end

    def capture_range_declaration(name)
      @ranges[name] = { min: "#{name}_min", max: "#{name}_max" }
    end
  end
end
