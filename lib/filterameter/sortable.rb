# frozen_string_literal: true

module Filterameter
  # = Sortable
  #
  # Mixin Sortable provides class methods <tt>sort</tt> and <tt>sorts</tt>.
  module Sortable
    extend ActiveSupport::Concern

    class_methods do
      # Declares a sort that can be read from the parameters and applied to the ActiveRecord query. The
      # <tt>parameter_name</tt> identifies the name of the parameter and is the default value for the attribute
      # name when none is specified in the options.
      #
      # The including class must implement `filter_coordinator`
      #
      # === Options
      #
      # [:name]
      #   Specify the attribute or scope name if the parameter name is not the same. The default value
      #   is the parameter name, so if the two match this can be left out.
      #
      # [:association]
      #   Specify the name of the association if the attribute or scope is nested.
      def sort(parameter_name, options = {})
        filter_coordinator.add_sort(parameter_name, options)
      end

      # Declares a list of filters that can be read from the parameters and applied to the query. The name can be either
      # an attribute or a scope. Declare filters individually with <tt>filter</tt> if more options are required.
      def sorts(*parameter_names)
        parameter_names.each { |parameter_name| filter(parameter_name) }
      end

      def default_sort(sort_and_direction_pairs)
        filter_coordinator.default_sort = sort_and_direction_pairs
      end
    end
  end
end
