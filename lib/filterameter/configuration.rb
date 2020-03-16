# frozen_string_literal: true

module Filterameter
  # = Configuration
  #
  # Class Configuration stores the following settings:
  # - action_on_undeclared_parameters
  # - action_on_validation_failure
  #
  # == Action on Undeclared Parameters
  # Occurs when the filter parameter contains any keys that are not defined. Valid actions are :log, :raise, and
  # false (do not take action). By default, development will log, test will raise, and production will do nothing.
  #
  # == Action on Validation Failure
  # Occurs when a filter parameter fails a validation. Valid actions are :log, :raise, and false (do not take action).
  # By default, development will log, test will raise, and production will do nothing.
  class Configuration
    attr_accessor :action_on_undeclared_parameters, :action_on_validation_failure

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
    end
  end
end
