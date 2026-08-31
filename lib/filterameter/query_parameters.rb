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
    attr_reader :filter_params, :sort_order, :requested_sort_order

    def initialize(request_parameters, default_sort: nil,
                   sort_strategy: SortStrategies::ReplacementSortStrategy.new)
      @request_params = request_parameters
      @sort_strategy = sort_strategy
      @default_sort = Helpers::SortNormalizer.normalize(default_sort) || {}
      @filter_params = @request_params.filter_params
      raw_sort = @request_params.sort_params
      @sort_requested = raw_sort.present?
      @requested_sort_order = @sort_requested ? parse_sort(raw_sort) : {}
      @sort_order = @sort_requested ? @requested_sort_order : @default_sort
    end

    # Returns the current filter and sort state with the page number replaced.
    def for_page(page_number)
      write_at_path(@request_params.filter_sort_and_pagination_params, @request_params.pagination_page_path,
                    page_number)
    end

    def for_size(page_size)
      write_at_path(current_query_params_without_page, @request_params.pagination_size_path, page_size)
    end

    # Returns the current filter state with the sort updated according to the sort strategy. The page number is
    # omitted, allowing the pagination library to use its configured first page.
    def for_sort(name, initial_direction: :asc)
      normalized_direction = Helpers::SortSerializer.normalize_direction(initial_direction)
      result = @sort_strategy.call(self, name, normalized_direction)
      override_sort(current_query_params_without_page, result)
    end

    def sorted_by?(name)
      @sort_order.key?(name.to_sym)
    end

    def sort_requested?
      @sort_requested
    end

    def default_sort_order
      @default_sort
    end

    def sort_direction(name)
      @sort_order[name.to_sym]
    end

    private

    def current_query_params_without_page
      delete_at_path(@request_params.filter_sort_and_pagination_params, @request_params.pagination_page_path)
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
      path = @request_params.sort_path
      if sort.empty?
        delete_at_path(params, path)
      else
        serialized = sort.map { |name, dir| Helpers::SortSerializer.serialize(name, dir) }
        write_at_path(params, path, serialized.one? ? serialized.first : serialized)
      end
    end

    def parse_sort(sort)
      Array.wrap(sort).each_with_object({}) do |s, hash|
        parsed = RequestedSort.parse(s.to_s)
        hash[parsed.name.to_sym] = parsed.direction
      end
    end
  end
end
