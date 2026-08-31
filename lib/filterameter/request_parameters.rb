# frozen_string_literal: true

module Filterameter
  # # Request Parameters
  #
  # Value object that normalizes incoming request params and provides structured access to
  # Filterameter filters, sorting, and pagination.
  #
  # By default, filter and sort params are read from the configured filter-key namespace, while
  # pagination params remain at the top level. When that namespace is disabled, all parameter types
  # are read from the top level.
  #
  # Exposes the configured pagination and sort parameter paths for link generation.
  class RequestParameters
    attr_reader :pagination_page_path, :pagination_size_path, :sort_path

    def initialize(params, declared_filter_parameter_names: nil)
      @params = normalize(params)
      @declared_filter_parameter_names = normalize_declared_names(declared_filter_parameter_names)
      config = Filterameter.configuration
      @filter_key = config.filter_key
      @sort_path = sort_parameter_path.freeze
      @pagination_page_path = config.pagination_page_param.dup.freeze
      @pagination_size_path = config.pagination_size_param.dup.freeze
      @pagination_roots = pagination_roots.freeze
    end

    # Returns the filter params, excluding sort and pagination.
    def filter_params
      filter_and_sort_params.except(:sort)
    end

    # Returns the raw sort value from the request (a string, array of strings, or nil).
    def sort_params
      filter_and_sort_params[:sort]
    end

    # Returns the filter and sort params, excluding pagination.
    def filter_and_sort_params
      params = if @filter_key
                 @params.fetch(filter_key) { @params.fetch(filter_key.to_s, {}) }
               else
                 flat_filter_and_sort_params
               end

      params.deep_dup
    end

    # Returns the filter, sort, and pagination params — the full set needed for link generation.
    def filter_sort_and_pagination_params
      return flat_query_params.deep_dup unless @filter_key

      @params.slice(filter_key, *@pagination_roots).deep_dup
    end

    private

    def normalize(params)
      hash = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
      hash.deep_symbolize_keys
    end

    def filter_key
      @filter_key.to_sym
    end

    def normalize_declared_names(names)
      names&.map(&:to_sym)
    end

    def sort_parameter_path
      @filter_key ? [@filter_key.to_sym, :sort] : [:sort]
    end

    def pagination_roots
      [@pagination_page_path.first, @pagination_size_path.first].uniq
    end

    def flat_filter_and_sort_params
      params = @params.except(*@pagination_roots)
      return params unless @declared_filter_parameter_names

      params.slice(*@declared_filter_parameter_names, :sort)
    end

    def flat_query_params
      return @params unless @declared_filter_parameter_names

      result = @params.slice(*@declared_filter_parameter_names, :sort)
      [@pagination_page_path, @pagination_size_path].each do |path|
        value = value_at_path(@params, path)
        write_at_path(result, path, value) unless value.nil?
      end
      result
    end

    def value_at_path(params, path)
      path.reduce(params) { |value, key| value.is_a?(Hash) ? value[key] : nil }
    end

    def write_at_path(params, path, value)
      container = path[0...-1].reduce(params) { |hash, key| hash[key] ||= {} }
      container[path.last] = value
    end
  end
end
