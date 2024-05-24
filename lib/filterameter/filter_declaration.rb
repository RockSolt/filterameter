# frozen_string_literal: true

require 'active_support/core_ext/array/wrap'

module Filterameter
  # = Filter Declaration
  #
  # Class FilterDeclaration captures the filter declaration within the controller.
  class FilterDeclaration
    VALID_RANGE_OPTIONS = [true, :min_only, :max_only].freeze

    attr_reader :name, :parameter_name, :association, :validations

    def initialize(parameter_name, options)
      @parameter_name = parameter_name.to_s

      validate_options(options)
      @name = options.fetch(:name, parameter_name).to_s
      @association = Array.wrap(options[:association]).presence
      @filter_on_empty = options.fetch(:filter_on_empty, false)
      @validations = Array.wrap(options[:validates])
      @raw_partial_options = options.fetch(:partial, false)
      @raw_range = options[:range]
    end

    def nested?
      !@association.nil?
    end

    def validations?
      !@validations.empty?
    end

    def filter_on_empty?
      @filter_on_empty
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

    def minimum?
      @raw_range == :min_only
    end

    def maximum?
      @raw_range == :max_only
    end

    private

    def validate_options(options)
      options.assert_valid_keys(:name, :association, :filter_on_empty, :validates, :partial, :range)
      validate_range(options[:range]) if options.key?(:range)
    end

    def validate_range(range)
      return if VALID_RANGE_OPTIONS.include?(range)

      raise ArgumentError, "Invalid range option: #{range}"
    end
  end
end
