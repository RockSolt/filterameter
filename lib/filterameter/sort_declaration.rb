# frozen_string_literal: true

module Filterameter
  # = Sort Declaration
  #
  # Class SortDeclaration captures the sort declaration within the controller. A sort declaration is also generated
  # from a FilterDeclaration when it is `sortable?`.
  class SortDeclaration
    attr_reader :name, :parameter_name, :association

    def initialize(parameter_name, options)
      @parameter_name = parameter_name.to_s

      validate_options(options)
      @name = options.fetch(:name, parameter_name).to_s
      @association = Array.wrap(options[:association]).presence
    end

    def nested?
      !@association.nil?
    end

    private

    def validate_options(options)
      options.assert_valid_keys(:name, :association)
    end
  end
end
