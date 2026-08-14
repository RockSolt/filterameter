# frozen_string_literal: true

module Filterameter
  # # Query Parameters
  #
  # Because Filterameter knows all about the filter and sort parameters in the query string, it is also able to
  # generate query parameters for similar links. For example, sorting by a different column or direction should still
  # carry all the same filters and page parameters; or pagination might require links with the same filtering and
  # sorting but a different page number or page size.
  #
  # QueryParameters is a value object containing the current query parameters. It provides helpers for generating
  # updated parameters:
  #
  # - `for_sort`: updates sorting, preserves filters and page size, and resets the page
  # - `for_page`: updates the page, preserves filters, sorting, and page size
  # - `for_size`: updates page size, preserves filters and sorting, and resets the page
  #
  # The return of each method are the arguments that can be passed to Rails path builders.
  class QueryParameters
    attr_reader :filter_params, :sort

    def self.build(params, default_sort: nil)
      new(params, default_sort:)
    end

    def initialize(params, default_sort: nil)
      @filter_key = Filterameter.configuration.filter_key
      @params = normalize(params)
      @default_sort = default_sort_value(default_sort)
      @filter_params = extract_filter_params
      @sort = @filter_params[:sort] || @default_sort
      @filter_params = @filter_params.except(:sort)
    end

    # Returns the current filter and sort state with the page number replaced.
    def for_page(page_number)
      current_query_params.merge(page: { number: page_number })
    end

    # Returns the current filter state with a single sort applied. Ascending sorts are represented without a prefix;
    # descending sorts are prefixed with `-`.
    def for_sort(name, direction: :asc)
      query_params_with_sort(sort_value(name, direction)).merge(page: { number: 1 })
    end

    private

    def normalize(params)
      hash = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
      hash.deep_symbolize_keys
    end

    def extract_filter_params
      return @params.except(:page) unless @filter_key

      @params.fetch(@filter_key.to_sym, {}).deep_dup
    end

    def current_query_params
      if @filter_key
        @params.slice(@filter_key.to_sym, :page).deep_dup
      else
        @params.deep_dup
      end
    end

    def query_params_with_sort(sort)
      if @filter_key
        { @filter_key.to_sym => @filter_params.merge(sort:) }
      else
        @filter_params.merge(sort:)
      end
    end

    def default_sort_value(default_sort)
      return if default_sort.nil?
      raise ArgumentError, 'default_sort must be a hash of sort names and directions' unless default_sort.is_a?(Hash)

      values = default_sort.map { |name, direction| sort_value(name, direction) }
      values.one? ? values.first : values
    end

    def sort_value(name, direction)
      case direction.to_sym
      when :asc then name.to_s
      when :desc then "-#{name}"
      else
        raise ArgumentError, 'direction must be :asc or :desc'
      end
    end
  end
end
