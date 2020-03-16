# frozen_string_literal: true

require 'active_support/core_ext/array/wrap'

module Filterameter
  # = Filter Declaration
  #
  # Class FilterDeclaration captures the filter declaration within the controller.
  class FilterDeclaration
    attr_reader :name, :parameter_name, :association, :validations

    def initialize(parameter_name, options)
      @parameter_name = parameter_name.to_s

      validate_options(options)
      @name = options.fetch(:name, parameter_name).to_s
      @association = options[:association]
      @filter_on_empty = options.fetch(:filter_on_empty, false)
      @validations = Array.wrap(options[:validates])
    end

    def nested?
      @association.present?
    end

    def validations?
      !@validations.empty?
    end

    def filter_on_empty?
      @filter_on_empty
    end

    private

    def validate_options(options)
      options.assert_valid_keys(:name, :association, :filter_on_empty, :validates)
    end
  end
end
