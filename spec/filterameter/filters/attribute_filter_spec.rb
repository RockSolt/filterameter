# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::AttributeFilter do
  let(:filter) { described_class.new(:color) }
  let(:query) { class_spy(Shirt) }

  it 'applies filter to query' do
    filter.apply(query, 'blue')
    expect(query).to have_received(:where).with(color: 'blue')
  end
end
