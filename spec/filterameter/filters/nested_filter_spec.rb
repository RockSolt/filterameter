# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::NestedFilter do
  let(:filter) { described_class.new(:brand, Brand, Filterameter::Filters::AttributeFilter.new(:name)) }
  let(:result) { filter.apply(Shirt.all, 'Happy Shirts') }

  it 'includes joins' do
    expect(result.joins_values).to contain_exactly(:brand)
  end

  it 'applies nested filter' do
    expect(result.where_values_hash('brands')).to match('name' => 'Happy Shirts')
  end
end
