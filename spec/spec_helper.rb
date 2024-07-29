# frozen_string_literal: true

require 'filterameter'
require 'simplecov'

SimpleCov.start

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed

  RSpec::Matchers.define :include_a_record_with do |expected_attributes|
    match do |records|
      expect(records).to include(a_hash_including(expected_attributes))
    end
  end

  RSpec::Matchers.define :sort_by do |expected|
    # this works on the assumption that adding an order that is already on the query does not change it
    match do |query|
      @expected = expected
      query == query.order(expected)
    end

    failure_message do |query|
      "Expected \n\t#{query.to_sql}\nto include the sort #{@expected}"
    end

    failure_message_when_negated do
      "Expected \n\t#{query.to_sql}\nnot to include the sort #{@expected}"
    end
  end
end

RSpec::Matchers.define_negated_matcher :not_match, :match
