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
    # `sort` is the requested sort, or the supplied default when the request has no explicit sort.
    attr_reader :filter_params, :sort

    def initialize(params, default_sort: nil)
      @filter_key = Filterameter.configuration.filter_key
      configure_pagination
      @params = normalize(params)
      @default_sort = default_sort_value(default_sort)
      @filter_params = extract_filter_params
      @sort = @filter_params[:sort] || @default_sort
      @filter_params = @filter_params.except(:sort)
    end

    # Returns the current filter and sort state with the page number replaced.
    def for_page(page_number)
      write_at_path(current_query_params, @pagination_page_param, page_number)
    end

    def for_size(page_size)
      write_at_path(current_query_params_without_page, @pagination_size_param, page_size)
    end

    # Returns the current filter state with a single sort applied. Ascending sorts are represented without a prefix;
    # descending sorts are prefixed with `-`. The page number is omitted, allowing the pagination library to use its
    # configured first page.
    def for_sort(name, direction: :asc)
      override_sort(current_query_params_without_page, sort_value(name, direction))
    end

    def sorted_by?(name)
      Array.wrap(@sort).any? { |s| s.to_s.delete_prefix('-') == name.to_s }
    end

    def sort_direction(name)
      return nil unless sorted_by?(name)

      Array.wrap(@sort).find { |s| s.to_s.delete_prefix('-') == name.to_s }.to_s.start_with?('-') ? :desc : :asc
    end

    private

    def configure_pagination
      @pagination_page_param = Filterameter.configuration.pagination_page_param
      @pagination_size_param = Filterameter.configuration.pagination_size_param
      @pagination_roots = [@pagination_page_param.first, @pagination_size_param.first].uniq
    end

    def normalize(params)
      hash = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
      hash.deep_symbolize_keys
    end

    def extract_filter_params
      return @params.except(*@pagination_roots) unless @filter_key

      @params.fetch(@filter_key.to_sym, {}).deep_dup
    end

    def current_query_params
      if @filter_key
        @params.slice(@filter_key.to_sym, *@pagination_roots).deep_dup
      else
        @params.deep_dup
      end
    end

    def current_query_params_without_page
      delete_at_path(current_query_params, @pagination_page_param)
    end

    # Methods `write_at_path` and `delete_at_path` introduce a fair amount of the complexity here. If this could assume
    # how the pagination parameters are stored, it could be much simpler. But the configuration allows for params at the
    # root (such as `page` and `per_page`) or nested under a key (such as `page[number]` and `page[size]`).
    #
    # All of which is to say, you can ignore these methods for the most part. The write method is also used to override
    # the sort, since that can also optionally be nested.

    def write_at_path(params, path, value)
      container = path[0...-1].reduce(params) do |hash, key|
        hash[key] = {} unless hash[key].is_a?(Hash)
        hash[key]
      end
      container[path.last] = value
      params
    end

    def delete_at_path(params, path)
      return params unless params.is_a?(Hash)

      key = path.first
      if path.one?
        params.delete(key)
      elsif (nested_params = params[key]).is_a?(Hash)
        delete_at_path(nested_params, path.drop(1))
        params.delete(key) if nested_params.empty?
      end
      params
    end

    def override_sort(params, sort)
      path = @filter_key ? [@filter_key.to_sym, :sort] : [:sort]
      write_at_path(params, path, sort)
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
