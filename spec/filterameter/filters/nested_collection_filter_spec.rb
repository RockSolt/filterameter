# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::NestedCollectionFilter do
  fixtures :brands, :shirts

  describe 'collection associations' do
    let(:filter) { described_class.new([:shirts], Shirt, Filterameter::Filters::AttributeFilter.new(:color)) }
    let(:result) { filter.apply(Brand.all, 'Blue') }

    it 'includes joins' do
      expect(result.joins_values).to contain_exactly(:shirts)
    end

    it('is distinct') { expect(result.distinct_value).to be true }

    it 'applies nested filter' do
      expect(result.where_values_hash('shirts')).to match('color' => 'Blue')
    end
  end
end
