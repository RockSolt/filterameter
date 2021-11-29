# frozen_string_literal: true

require 'filterameter/configuration'
require 'filterameter/declarative_controller_filters'
require 'filterameter/declarative_filters'
require 'filterameter/exceptions'

# = Filterameter
#
# Module Filterameter can be mixed into a controller to provide the DSL to describe each controller's filters.
#
# The model class must be declared if it cannot be derived. It can be derived if (A) the model is not namespaced and its
# name matches the controller name (for example BrandsController -> Brand) or (B) both the controller and model share
# the same namespace and name.
module Filterameter
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
