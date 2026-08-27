# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Helpers::SortNormalizer do
  describe '.normalize' do
    context 'with no sort' do
      it 'returns nil' do
        expect(described_class.normalize(nil)).to be_nil
      end
    end

    context 'with a sort hash' do
      it 'converts names to symbols and normalizes directions' do
        sort = { 'created_at' => 'desc', updated_at: :asc }

        expect(described_class.normalize(sort)).to eq(created_at: :desc, updated_at: :asc)
      end

      it 'returns an empty hash for an empty sort' do
        expect(described_class.normalize({})).to eq({})
      end
    end

    context 'with a sort that is not a hash' do
      it 'raises an ArgumentError' do
        expect { described_class.normalize('-created_at') }
          .to raise_error(ArgumentError, 'default_sort must be a hash of sort names and directions')
      end
    end

    context 'with an invalid direction' do
      it 'raises the direction validation error' do
        expect { described_class.normalize(created_at: :sideways) }
          .to raise_error(ArgumentError, 'direction must be :asc or :desc')
      end
    end
  end
end
