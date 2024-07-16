# frozen_string_literal: true

module Filterameter
  module Options
    # = Partial Options
    #
    # Class PartialOptions parses the options passed in as partial, then exposes those. Here are the options along with
    # their valid values:
    # - match: anywhere (default), from_start, dynamic
    # - case_sensitive: true, false (default)
    #
    # Options may be specified by passing a hash with the option keys:
    #
    #   partial: { match: :from_start, case_sensitive: true }
    #
    # There are two shortcuts: the partial option can be declared with `true`, which just uses the defaults; or the
    # partial option can be declared with the match option directly, such as partial: :from_start.
    class PartialOptions
      VALID_OPTIONS = %i[match case_sensitive].freeze
      VALID_MATCH_OPTIONS = %w[anywhere from_start dynamic].freeze

      def initialize(options)
        @match = 'anywhere'
        @case_sensitive = false

        case options
        when TrueClass
          nil
        when Hash
          evaluate_hash(options)
        when String, Symbol
          assign_match(options)
        end
      end

      def case_sensitive?
        @case_sensitive
      end

      def match_anywhere?
        @match == 'anywhere'
      end

      def match_from_start?
        @match == 'from_start'
      end

      def match_dynamically?
        @match == 'dynamic'
      end

      def to_s
        if case_sensitive?
          case_sensitive_to_s
        elsif match_anywhere?
          'true'
        else
          ":#{@match}"
        end
      end

      private

      def evaluate_hash(options)
        options.assert_valid_keys(:match, :case_sensitive)
        assign_match(options[:match]) if options.key?(:match)
        assign_case_sensitive(options[:case_sensitive]) if options.key?(:case_sensitive)
      end

      def assign_match(value)
        validate_match(value)
        @match = value.to_s
      end

      def validate_match(value)
        return if VALID_MATCH_OPTIONS.include? value.to_s

        raise ArgumentError,
              "Invalid match option for partial: #{value}. Valid options are #{VALID_MATCH_OPTIONS.to_sentence}"
      end

      def assign_case_sensitive(value)
        validate_case_sensitive(value)
        @case_sensitive = value
      end

      def validate_case_sensitive(value)
        return if value.is_a?(TrueClass) || value.is_a?(FalseClass)

        raise ArgumentError, "Invalid case_sensitive option for partial: #{value}. Valid options are true and false."
      end

      def case_sensitive_to_s
        match_anywhere? ? '{ case_sensitive: true }' : "{ match: :#{@match}, case_sensitive: true }"
      end
    end
  end
end
