# frozen_string_literal: true

require 'active_model/attribute_assignment'
require 'active_model/validations'

module Filterameter
  # = Parameters
  #
  # Class Parameters is sub-classed to provide controller-specific validations.
  class ParametersBase
    include ActiveModel::Validations

    def self.build_sub_class(declarations)
      Class.new(self).tap do |sub_class|
        declarations.select(&:validations?).each do |declaration|
          sub_class.add_validation(declaration.parameter_name, declaration.validations)
        end
      end
    end

    def self.name
      'ControllerParameters'
    end

    def self.add_validation(parameter_name, validations)
      attr_accessor parameter_name

      default_options = { allow_nil: true }
      validations.each do |validation|
        validates parameter_name, default_options.merge(validation)
      end
    end

    def initialize(attributes)
      attributes.each { |k, v| assign_attribute(k, v) }
    end

    private

    def assign_attribute(key, value)
      setter = :"#{key}="
      public_send(setter, value) if respond_to?(setter)
    end
  end
end
