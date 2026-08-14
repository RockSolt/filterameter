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
  # and `[:per_page]`, for top-level pagination parameters.
  class Configuration
    attr_accessor :action_on_undeclared_parameters, :action_on_validation_failure, :filter_key
    attr_reader :pagination_page_param, :pagination_size_param

    def initialize
      @action_on_undeclared_parameters = @action_on_validation_failure = default_action

      @filter_key = :filter
      configure_pagination
    end

    def pagination_page_param=(param)
      @pagination_page_param = pagination_param(param)
    end

    def pagination_size_param=(param)
      @pagination_size_param = pagination_param(param)
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
  end
end
