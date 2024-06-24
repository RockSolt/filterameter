# frozen_string_literal: true

require 'active_support/core_ext/array/wrap'

module Filterameter
  # = Filter Declaration
  #
  # Class FilterDeclaration captures the filter declaration within the controller.
  #
  # When the min_only or max_only range option is specified, in addition to the attribute filter which carries that
  # option, the registry builds a duplicate declaration that also carries the range_type flag (as either :minimum
  # or :maximum).
  #
  # The predicate methods `min_only?` and `max_only?` answer what was declared; the predicate methods `minimum_range?`
  # and `maximum_range?` answer what type of filter should be built.
  class FilterDeclaration
    VALID_RANGE_OPTIONS = [true, :min_only, :max_only].freeze

    attr_reader :name, :parameter_name, :association, :validations

    def initialize(parameter_name, options, range_type: nil)
      @parameter_name = parameter_name.to_s

      validate_options(options)
      @name = options.fetch(:name, parameter_name).to_s
      @association = Array.wrap(options[:association]).presence
      @validations = Array.wrap(options[:validates])
      @raw_partial_options = options.fetch(:partial, false)
      @raw_range = options[:range]
      @range_type = range_type
      @sortable = options.fetch(:sortable, true)
    end

    def nested?
      !@association.nil?
    end

    def validations?
      !@validations.empty?
    end

    def partial_search?
      partial_options.present?
    end

    def partial_options
      @partial_options ||= @raw_partial_options ? Options::PartialOptions.new(@raw_partial_options) : nil
    end

    def range_enabled?
      @raw_range.present?
    end

    def range?
      @raw_range == true
    end

    def min_only?
      @raw_range == :min_only
    end

    def max_only?
      @raw_range == :max_only
    end

    def minimum_range?
      @range_type == :minimum
    end

    def maximum_range?
      @range_type == :maximum
    end

    def sortable?
      @sortable
    end

    private

    def validate_options(options)
      options.assert_valid_keys(:name, :association, :validates, :partial, :range, :sortable)
      validate_range(options[:range]) if options.key?(:range)
    end

    def validate_range(range)
      return if VALID_RANGE_OPTIONS.include?(range)

      raise ArgumentError, "Invalid range option: #{range}"
    end
  end
end
