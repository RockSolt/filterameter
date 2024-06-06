# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::ScopeFilter do
  let(:filter) { described_class.new(:the_scope) }
  let(:query) { spy('query') }

  it 'applies filter to query' do
    filter.apply(query, 20)
    expect(query).to have_received(:the_scope).with(20)
  end
end
