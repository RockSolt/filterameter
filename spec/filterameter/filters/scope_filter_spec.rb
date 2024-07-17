# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::ScopeFilter do
  let(:filter) { described_class.new(:the_scope) }
  let(:query) { spy('query') }

  it 'applies filter to query' do
    filter.apply(query, 20)
    expect(query).to have_received(:the_scope).with(20)
  end

  context 'with valid scope' do
    let(:filter) { described_class.new(:in_progress) }

    it 'is valid' do
      expect(filter.valid?(Project)).to be true
    end
  end

  context 'with a class method that is not a scope' do
    let(:filter) { described_class.new(:not_a_scope) }

    it 'is not valid' do
      expect(filter.valid?(Activity)).to be false
    end

    it 'reports error' do
      filter.valid?(Activity)
      expect(filter.errors).to contain_exactly "Activity class method 'not_a_scope' is not a scope"
    end
  end
end
