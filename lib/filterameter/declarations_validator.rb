# frozen_string_literal: true

module Filterameter
  # # Declarations Validator
  #
  # Class DeclarationsValidtor fetches each filter and sort from the registry to validate the declaration. This class
  # can be accessed from the controller as `declarations_validator` (via the FilterCoordinator) and be used in tests.
  #
  # Use the `valid?` method to test, then report errors with the `errors` attribute.
  #
  # A test in RSpec might look like this:
  #
  #     expect(WidgetsController.declarations_validator).to be_valid
  #
  # In Minitest it might look like this:
  #
  #     validator = WidgetsController.declarations_validator
  #     assert_predicate validator, :valid?, -> { validator.errors }
  class DeclarationsValidator
    include Filterameter::Errors

    def initialize(controller_name, model, registry)
      @controller_name = controller_name
      @model = model
      @registry = registry
    end

    def inspect
      "filter declarations on #{@controller_name.titleize}Controller"
    end

    def errors
      @errors&.join("\n")
    end

    private

    def validate(_)
      @errors.push(*validation_errors_for('filter', fetch_filters))
      @errors.push(*validation_errors_for('sort', fetch_sorts))
    end

    def fetch_filters
      @registry.filter_parameter_names.index_with { |name| fetch_filter(name) }
    end

    def fetch_filter(name)
      @registry.fetch_filter(name)
    rescue StandardError => e
      FactoryErrors.new(e)
    end

    def fetch_sorts
      (@registry.sort_parameter_names - @registry.filter_parameter_names).index_with { |name| fetch_sort(name) }
    end

    def fetch_sort(name)
      @registry.fetch_sort(name)
    rescue StandardError => e
      FactoryErrors.new(e)
    end

    def validation_errors_for(type, items)
      items.select { |_name, item| item.respond_to? :valid? }
           .reject { |_name, item| item.valid?(@model) }
           .map { |name, item| error_message(type, name, item.errors) }
    end

    def error_message(type, name, errors)
      "\nInvalid #{type} for '#{name}':\n  #{errors.join("\n  ")}"
    end

    # # Factory Errors
    #
    # Class FactoryErrors is swapped in if the fetch from a factory fails. It is always invalid and provides the reason.
    class FactoryErrors
      attr_reader :errors

      def initialize(error)
        @errors = [wrap_if_unexpected(error)]
      end

      def valid?(_)
        false
      end

      def to_s
        @errors.join("\n")
      end

      private

      def wrap_if_unexpected(error)
        return error if error.is_a?(Filterameter::DeclarationErrors::DeclarationError)

        Filterameter::DeclarationErrors::UnexpectedError.new(error)
      end
    end
  end
end
