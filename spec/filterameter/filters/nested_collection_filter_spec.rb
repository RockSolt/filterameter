# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::NestedCollectionFilter do
  describe 'collection associations' do
    let(:filter) { described_class.new([:activities], Activity, Filterameter::Filters::AttributeFilter.new(:name)) }
    let(:result) { filter.apply(Project.all, 'The Activity Name') }

    it 'includes joins' do
      expect(result.joins_values).to contain_exactly(:activities)
    end

    it('is distinct') { expect(result.distinct_value).to be true }

    it 'applies nested filter' do
      expect(result.where_values_hash('activities')).to match('name' => 'The Activity Name')
    end

    it 'is valid' do
      expect(filter.valid?(Project)).to be true
    end
  end
end
