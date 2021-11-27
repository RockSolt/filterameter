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
      @declarations[parameter_name.to_s] = Filterameter::FilterDeclaration.new(parameter_name, options).tap do |fd|
        add_declarations_for_range(fd, options, parameter_name) if fd.range_enabled?
      end
    end

    def fetch(name)
      name = name.to_s
      @filters.fetch(name) do
        raise Filterameter::Exceptions::UndeclaredParameterError, name unless filter_names.include?(name)

        @filters[name] = @filter_factory.build(@declarations[name])
      end
    end

    def filter_names
      @declarations.keys
    end

    def filter_declarations
      @declarations.values
    end

    private

    # if range is enabled, then in addition to the attribute filter this also adds min and/or max filters
    def add_declarations_for_range(attribute_declaration, options, parameter_name)
      add_range_minimum(parameter_name, options) if attribute_declaration.range? || attribute_declaration.minimum?
      add_range_maximum(parameter_name, options) if attribute_declaration.range? || attribute_declaration.maximum?
      capture_range_declaration(parameter_name) if attribute_declaration.range?
    end

    def add_range_minimum(parameter_name, options)
      parameter_name_min = "#{parameter_name}_min"
      @declarations[parameter_name_min] = Filterameter::FilterDeclaration.new(parameter_name_min,
                                                                              options.merge(range: :min_only))
    end

    def add_range_maximum(parameter_name, options)
      parameter_name_min = "#{parameter_name}_max"
      @declarations[parameter_name_min] = Filterameter::FilterDeclaration.new(parameter_name_min,
                                                                              options.merge(range: :max_only))
    end

    def capture_range_declaration(name)
      @ranges[name] = { min: "#{name}_min", max: "#{name}_max" }
    end
  end
end
