# frozen_string_literal: true

require 'filterameter/controller_filters'

module Filterameter
  # = Declarative Controller Filters
  #
  # Mixin DeclarativeControllerFilters can included in controllers to enable the filter DSL.
  module DeclarativeControllerFilters
    extend ActiveSupport::Concern

    class_methods do
      def filter_model(model_class, query_var_name = nil)
        controller_filters.model_class = model_class
        filter_query_var_name(query_var_name) if query_var_name.present?
      end

      def filter_query_var_name(query_variable_name)
        controller_filters.query_variable_name = query_variable_name
      end

      # Declares a filter that can be read from the parameters and applied to the ActiveRecord query. The <tt>name</tt>
      # identifies the name of the parameter and is the default value to determine the criteria to be applied. The name
      # can be either an attribute or a scope.
      #
      # === Options
      #
      # [:name]
      #   Specify the attribute or scope name if the parameter name is not the same. The default value
      #   is the parameter name, so if the two match this can be left out.
      #
      # [:association]
      #   Specify the name of the association if the attribute or scope is nested.
      #
      # [:validates]
      #   Specify a validation if the parameter value should be validated. This uses ActiveModel validations;
      #   please review those for types of validations and usage.
      #
      # [:partial]
      #   Specify the partial option if the filter should do a partial search (SQL's `LIKE`). The partial
      #   option accepts a hash to specify the search behavior. Here are the available options:
      #   - match: anywhere (default), from_start, dynamic
      #   - case_sensitive: true, false (default)
      #
      #   There are two shortcuts: : the partial option can be declared with `true`, which just uses the
      #   defaults; or the partial option can be declared with the match option directly,
      #   such as `partial: :from_start`.
      #
      # [:range]
      #   Specify a range option if the filter also allows ranges to be searched. The range option accepts
      #   the following options:
      #   - true: enables two additional parameters with attribute name plus suffixes <tt>_min</tt> and <tt>_max</tt>
      #   - :min_only: enables additional parameter with attribute name plus suffix <tt>_min</tt>
      #   - :max_only: enables additional parameter with attribute name plus suffix <tt>_max</tt>
      def filter(name, options = {})
        controller_filters.add_filter(name, options)
      end

      def filters(*names)
        names.each { |name| filter(name) }
      end

      def controller_filters
        @controller_filters ||= Filterameter::ControllerFilters.new(controller_name, controller_path)
      end
    end

    private

    def build_filtered_query
      var_name = "@#{self.class.controller_filters.query_variable_name}"
      instance_variable_set(
        var_name,
        self.class.controller_filters.build_query(params.to_unsafe_h.fetch(:filter, {}),
                                                  instance_variable_get(var_name))
      )
    end
  end
end
