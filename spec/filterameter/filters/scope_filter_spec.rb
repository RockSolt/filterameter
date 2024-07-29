# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::ScopeFilter do
  let(:filter) { described_class.new(:in_progress) }
  let(:query) { class_spy(Project) }

  it 'applies filter to query' do
    filter.apply(query, true)
    expect(query).to have_received(:in_progress).with(true)
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
      expect(filter.errors).to contain_exactly(
        Filterameter::DeclarationErrors::NotAScopeError.new('Activity', :not_a_scope)
      )
    end
  end
end
