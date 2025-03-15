# frozen_string_literal: true

module Filterameter
  # # Declarative Controller Filters
  #
  # Mixin DeclarativeFilters should be included in controllers to enable the filter DSL.
  module DeclarativeFilters
    extend ActiveSupport::Concern

    class_methods do
      delegate :declarations_validator, to: :filter_coordinator

      # Declares a filter that can be read from the parameters and applied to the
      # ActiveRecord query. The `name` identifies the name of the parameter and is the
      # default value to determine the criteria to be applied. The name can be either
      # an attribute or a scope.
      #
      # ## Options
      #
      # The declaration can also include an `options` hash to specialize the behavior of the filter.
      #
      # * **name**: Specify the attribute or scope name if the parameter name is not the same. The default value is the
      #   parameter name, so if the two match this can be left out.
      #
      # * **association**: Specify the name of the association if the attribute or scope is nested. Use an array if the
      #   asociation is more than one level.
      #
      # * **validates**: Specify a validation if the parameter value should be validated. This uses ActiveModel
      #   validations; please review those for types of validations and usage.
      #
      # * **partial**: Specify the partial option if the filter should do a partial search (SQL's `LIKE`). The partial
      #   option accepts a hash to specify the search behavior.
      #
      #   Here are the available options:
      #   *   match: `:anywhere` (default), `:from_start`, `:dynamic`
      #   *   case_sensitive: `true`, `false` (default)
      #
      #   There are two shortcuts: the partial option can be declared with `true`,
      #   which just uses the defaults; or the partial option can be declared with
      #   the match option directly, such as `partial: :from_start`.
      #
      # * **range**: Specify a range option if the filter also allows ranges to be searched. The range option accepts
      #   the following options:
      #     *   true: enables two additional parameters with attribute name plus
      #         suffixes `_min` and `_max`
      #     *   min_only: enables additional parameter with attribute name plus
      #         suffix `_min`
      #     *   max_only: enables additional parameter with attribute name plus
      #         suffix `_max`
      #
      # * **sortable**: By default most filters are sortable. To prevent an attribute filter from being sortable, set
      #   the option to `false`.
      #
      # Options examples:
      #
      #     filter :status, name: :current_status
      #     filter :manager_id, association: :department
      #     filter :business_unit_name, name: :name, association: [:department, :business_unit]
      #     filter :size, validates: { inclusion: { in: %w[Small Medium Large], allow_multiple_values: true } }
      #     filter :description, partial: true
      #     filter :department_name, partial: :from_start
      #     filter :reason, partial: { match: :dynamic, case_sensitive: true }
      #     filter :price, range: true
      def filter(name, options = {})
        filter_coordinator.add_filter(name, options)
      end

      # Declares a list of filters without options. Filters that require options must be declared with `filter`.
      def filters(*names)
        names.each { |name| filter(name) }
      end

      # Declares a sort that can be read from the parameters and applied to the
      # ActiveRecord query. The `parameter_name` identifies the name of the parameter
      # and is the default value for the attribute name when none is specified in the
      # options.
      #
      # ## Options
      #
      # The declaration can also include an `options` hash to specialize the behavior of the sort.
      #
      # * **name**: Specify the attribute or scope name if the parameter name is not the same. The default value is the
      #   parameter name, so if the two match this can be left out.
      #
      # * **association**: Specify the name of the association if the attribute or scope is nested.
      #
      # Options example:
      #
      #     sort :project_created_at, name: :created_at, association: :project
      def sort(parameter_name, options = {})
        filter_coordinator.add_sort(parameter_name, options)
      end

      # Declares a list of sorts without options. Sorts that require options must be declared with `sort`.
      def sorts(*parameter_names)
        parameter_names.each { |parameter_name| filter(parameter_name) }
      end

      # Declares a default sort order for the query. Specify a list of sort names and directions as pairs.
      def default_sort(sort_and_direction_pairs)
        filter_coordinator.default_sort = sort_and_direction_pairs
      end

      # Rails conventions are used to determine the controller's model. For example, the PhotosController builds a query
      # against the Photo model. If a controller is namespaced, the model will first be looked up without the namespace,
      # then with the namespace.
      #
      # **If the conventions do not provide the correct model**, the model can be named explicitly with the following:
      #
      # ```ruby
      # filter_model 'Picture'
      # ```
      #
      # An optional second parameter can be used to specify the variable name. Both the model and the variable name can
      # be specified with this short-cut. For example, to use the Picture model and store the results as `@data`, use
      # the following:
      #
      #     filter_model 'Picture', :data
      #
      # **Important:** If the `filter_model` declaration is used, it must be before any filter or sort declarations.
      def filter_model(model_class, query_var_name = nil)
        filter_coordinator.model_class = model_class
        filter_query_var_name(query_var_name) if query_var_name.present?
      end

      # When using the before action callback `build_filtered_query`, the query is assigned to an instance variable with
      # the name of the model pluralized. For example, the Photo model will use the variable `@photos`.
      #
      # To use a different variable name with the callback, assign it with `filter_query_var_name`. For example, if the
      # query is stored as `@data`, use the following:
      #
      #     filter_query_var_name :data
      def filter_query_var_name(query_variable_name)
        filter_coordinator.query_variable_name = query_variable_name
      end

      def filter_coordinator
        @filter_coordinator ||= Filterameter::FilterCoordinator.new(controller_name, controller_path)
      end
    end

    # Returns an ActiveRecord query from the filter parameters.
    #
    #     def index
    #       @widgets = build_query_from_filters
    #     end
    #
    # The method optionally takes a starting query. For example, this restricts the results
    # to only active widgets:
    #
    #     def index
    #       @widgets = build_query_from_filters(Widgets.where(active: true))
    #     end
    #
    # The starting query can also be used to provide eager loading:
    #
    #     def index
    #       @widgets = build_query_from_filters(Widgets.includes(:manufacturer))
    #     end
    def build_query_from_filters(starting_query = nil)
      self.class.filter_coordinator.build_query(filter_parameters, starting_query)
    end

    def filter_parameters
      filter_key = Filterameter.configuration.filter_key

      if filter_key
        params.to_unsafe_h.fetch(filter_key, {})
      else
        params.to_unsafe_h.slice(*self.class.filter_coordinator.filter_parameter_names, :sort)
      end
    end

    private

    def build_filtered_query
      var_name = "@#{self.class.filter_coordinator.query_variable_name}"
      starting_query = instance_variable_get(var_name)
      instance_variable_set(var_name, build_query_from_filters(starting_query))
    end
  end
end
