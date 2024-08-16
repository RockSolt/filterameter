# frozen_string_literal: true

module Filterameter
  # # Filterable
  #
  # Mixin Filterable provides class methods `filter` and `filters`.
  module Filterable
    extend ActiveSupport::Concern

    class_methods do
      # Declares a filter that can be read from the parameters and applied to the
      # ActiveRecord query. The `name` identifies the name of the parameter and is the
      # default value to determine the criteria to be applied. The name can be either
      # an attribute or a scope.
      #
      # ### Options
      #
      # :name
      # :   Specify the attribute or scope name if the parameter name is not the same.
      #     The default value is the parameter name, so if the two match this can be
      #     left out.
      #
      #
      # :association
      # :   Specify the name of the association if the attribute or scope is nested.
      #
      #
      # :validates
      # :   Specify a validation if the parameter value should be validated. This uses
      #     ActiveModel validations; please review those for types of validations and
      #     usage.
      #
      #
      # :partial
      # :   Specify the partial option if the filter should do a partial search (SQL's
      #     `LIKE`). The partial option accepts a hash to specify the search behavior.
      #
      #     Here are the available options:
      #     *   match: anywhere (default), from_start, dynamic
      #     *   case_sensitive: true, false (default)
      #
      #     There are two shortcuts: : the partial option can be declared with `true`,
      #     which just uses the defaults; or the partial option can be declared with
      #     the match option directly, such as `partial: :from_start`.
      #
      #
      # :range
      # :   Specify a range option if the filter also allows ranges to be searched.
      #     The range option accepts the following options:
      #     *   true: enables two additional parameters with attribute name plus
      #         suffixes `_min` and `_max`
      #     *   :min_only: enables additional parameter with attribute name plus
      #         suffix `_min`
      #     *   :max_only: enables additional parameter with attribute name plus
      #         suffix `_max`
      #
      def filter(name, options = {})
        filter_coordinator.add_filter(name, options)
      end

      # Declares a list of filters that can be read from the parameters and applied to
      # the query. The name can be either an attribute or a scope. Declare filters
      # individually with `filter` if more options are required.
      def filters(*names)
        names.each { |name| filter(name) }
      end
    end
  end
end
