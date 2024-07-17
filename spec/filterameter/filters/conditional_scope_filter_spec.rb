# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::ConditionalScopeFilter do
  let(:filter) { described_class.new(:the_scope) }
  let(:query) { spy('query') }

  it 'applies filter to query when true' do
    filter.apply(query, true)
    expect(query).to have_received('the_scope')
  end

  it 'does not apply filter to query when false' do
    filter.apply(query, false)
    expect(query).not_to have_received('the_scope')
  end

  context 'with valid conditional scope' do
    let(:filter) { described_class.new(:incomplete) }

    it 'is valid' do
      expect(filter.valid?(Activity)).to be true
    end
  end

  context 'with a class method that is not a scope' do
    let(:filter) { described_class.new(:not_a_conditional_scope) }

    it 'is not valid' do
      expect(filter.valid?(Activity)).to be false
    end

    it 'reports error' do
      filter.valid?(Activity)
      expect(filter.errors).to contain_exactly "Activity class method 'not_a_conditional_scope' is not a scope"
    end
  end

  context 'with inline scope that takes an argument' do
    let(:filter) { described_class.new(:inline_with_arg) }

    it 'is not valid' do
      expect(filter.valid?(Activity)).to be false
    end

    it 'reports error' do
      filter.valid?(Activity)
      expect(filter.errors).to contain_exactly(
        "Activity scope 'inline_with_arg' needs to be written as a class method, not as an inline scope"
      )
    end
  end
end
