# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::ScopeFilter do
  let(:filter) { described_class.new(:percent_reduced) }
  let(:query) { class_spy(Price) }

  it 'applies filter to query' do
    filter.apply(query, 20)
    expect(query).to have_received(:percent_reduced).with(20)
  end
end
