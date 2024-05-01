# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::NestedCollectionFilter do
  let(:filter) { described_class.new(:brand_id, Shirt, Filterameter::Filters::AttributeFilter.new(:color)) }
  let(:result) { filter.apply(Brand.all, 'Blue') }

  it 'generates valid sql' do
    expect { result.explain }.not_to raise_exception
  end

  it 'includes sub-query' do
    sub_query = Shirt.where(color: 'Blue').select(:brand_id).distinct.to_sql
    expect(result.to_sql).to include sub_query
  end
end
