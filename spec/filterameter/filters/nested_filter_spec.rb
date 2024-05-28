# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::NestedFilter do
  fixtures :shirts, :brands

  let(:filter) { described_class.new([:brand], Brand, Filterameter::Filters::AttributeFilter.new(:name)) }
  let(:result) { filter.apply(Shirt.all, 'Happy Shirts') }

  it 'includes joins' do
    expect(result.joins_values).to contain_exactly(:brand)
  end

  it 'applies nested filter' do
    expect(result.where_values_hash('brands')).to match('name' => 'Happy Shirts')
  end

  describe 'multi-level associations' do
    fixtures :vendors

    context 'with attribute filter' do
      let(:filter) { described_class.new(%i[brand vendor], Vendor, Filterameter::Filters::AttributeFilter.new(:name)) }
      let(:result) { filter.apply(Shirt.all, 'Happy House') }

      it 'includes builds nested hash for joins' do
        expect(result.joins_values).to contain_exactly({ brand: { vendor: {} } })
      end

      it 'applies nested filter' do
        expect(result.map(&:brand).map(&:vendor).map(&:name).uniq)
          .to eq(['Happy House']), "The following query did not return the expected results: #{result.to_sql}"
      end
    end

    context 'with scope filter' do
      let(:filter) { described_class.new(%i[brand vendor], Vendor, Filterameter::Filters::ScopeFilter.new(:ships_by)) }
      let(:result) { filter.apply(Shirt.all, 5.days.from_now) }

      it 'includes builds nested hash for joins' do
        expect(result.joins_values).to contain_exactly({ brand: { vendor: {} } })
      end

      it 'applies nested filter' do
        expect(result.map(&:brand).map(&:vendor).map(&:name).uniq)
          .to eq(['Happy House']), "The following query did not return the expected results: #{result.to_sql}"
      end
    end
  end
end
