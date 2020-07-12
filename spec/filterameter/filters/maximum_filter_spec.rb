# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::MaximumFilter do
  let(:filter) { described_class.new(Price, :current) }
  let(:query) { filter.apply(Price.all, 10.99) }

  it 'valid sql' do
    expect { query.explain }.not_to raise_exception
  end

  it 'applies criteria' do
    expect(query.to_sql).to include '"prices"."current" <= 10.99'
  end
end
