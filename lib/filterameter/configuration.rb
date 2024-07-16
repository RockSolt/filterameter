# frozen_string_literal: true

module Filterameter
  # = Configuration
  #
  # Class Configuration stores the following settings:
  # - action_on_undeclared_parameters
  # - action_on_validation_failure
  # - filter_key
  #
  # == Action on Undeclared Parameters
  #
  # Occurs when the filter parameter contains any keys that are not defined. Valid actions are :log, :raise, and
  # false (do not take action). By default, development will log, test will raise, and production will do nothing.
  #
  # == Action on Validation Failure
  #
  # Occurs when a filter parameter fails a validation. Valid actions are :log, :raise, and false (do not take action).
  # By default, development will log, test will raise, and production will do nothing.
  #
  # == Filter Key
  #
  # By default, the filter parameters are nested under the key :filter. Use this setting to override the key.
  #
  # If the filter parameters are NOT nested, set this to false. Doing so will restrict the filter parameters to only
  # those that have been declared, meaning undeclared parameters be ignored (and the action_on_undeclared_parameters
  # configuration option does not come into play).
  class Configuration
    attr_accessor :action_on_undeclared_parameters, :action_on_validation_failure, :filter_key

    def initialize
      @action_on_undeclared_parameters =
        @action_on_validation_failure =
          if Rails.env.development?
            :log
          elsif Rails.env.test?
            :raise
          else
            false
          end

      @filter_key = :filter
    end
  end
end
