# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::ConditionalScopeFilter do
  let(:filter) { described_class.new(:on_sale) }
  let(:query) { class_spy(Price) }

  it 'applies filter to query when true' do
    filter.apply(query, true)
    expect(query).to have_received('on_sale')
  end

  it 'does not apply filter to query when false' do
    filter.apply(query, false)
    expect(query).not_to have_received('on_sale')
  end
end
