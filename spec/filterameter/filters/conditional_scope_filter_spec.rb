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
end
