# frozen_string_literal: true

module Filterameter
  # # Configuration
  #
  # Class Configuration stores the following settings:
  # *   action_on_undeclared_parameters
  # *   action_on_validation_failure
  # *   filter_key
  # *   pagination_page_param
  # *   pagination_size_param
  #
  # ## Action on Undeclared Parameters
  #
  # Occurs when the filter parameter contains any keys that are not defined. Valid
  # actions are :log, :raise, and false (do not take action). By default,
  # development will log, test will raise, and production will do nothing.
  #
  # ## Action on Validation Failure
  #
  # Occurs when a filter parameter fails a validation. Valid actions are :log,
  # :raise, and false (do not take action). By default, development will log, test
  # will raise, and production will do nothing.
  #
  # ## Filter Key
  #
  # By default, the filter parameters are nested under the key :filter. Use this
  # setting to override the key.
  #
  # If the filter parameters are NOT nested, set this to false. Doing so will
  # restrict the filter parameters to only those that have been declared, meaning
  # undeclared parameters are ignored (and the action_on_undeclared_parameters
  # configuration option does not come into play).
  #
  # ## Pagination Parameters
  #
  # Pagination parameter paths are arrays of keys. They default to
  # `[:page, :number]` and `[:page, :size]`, producing the nested parameters
  # `page[number]` and `page[size]`. Use a single-key path, such as `[:page]`
  # and `[:per_page]`, for top-level pagination parameters. Pagination paths
  # cannot be rooted at the configured filter key.
  class Configuration
    attr_accessor :action_on_undeclared_parameters, :action_on_validation_failure
    attr_reader :pagination_page_param, :pagination_size_param, :filter_key

    def initialize
      @action_on_undeclared_parameters = @action_on_validation_failure = default_action

      @filter_key = :filter
      configure_pagination
    end

    def filter_key=(key)
      validate_pagination_paths(key)
      @filter_key = key
    end

    def pagination_page_param=(param)
      path = pagination_param(param)
      validate_pagination_path(path, :pagination_page_param)
      @pagination_page_param = path
    end

    def pagination_size_param=(param)
      path = pagination_param(param)
      validate_pagination_path(path, :pagination_size_param)
      @pagination_size_param = path
    end

    private

    def default_action
      if Rails.env.development?
        :log
      elsif Rails.env.test?
        :raise
      else
        false
      end
    end

    def configure_pagination
      self.pagination_page_param = %i[page number]
      self.pagination_size_param = %i[page size]
    end

    def pagination_param(param)
      path = Array(param).map(&:to_sym)
      raise ArgumentError, 'pagination parameter path cannot be empty' if path.empty?

      path
    end

    def validate_pagination_paths(filter_key)
      return unless filter_key

      validate_pagination_path(@pagination_page_param, :pagination_page_param, filter_key)
      validate_pagination_path(@pagination_size_param, :pagination_size_param, filter_key)
    end

    def validate_pagination_path(path, name, filter_key = @filter_key)
      return unless filter_key && path&.first == filter_key.to_sym

      raise ArgumentError, "#{name} cannot be nested under filter_key (#{filter_key.inspect})"
    end
  end
end
