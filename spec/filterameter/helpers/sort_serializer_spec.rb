# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Helpers::SortSerializer do
  describe '.deserialize' do
    context 'with no sign' do
      it 'returns asc direction' do
        result = described_class.deserialize('created_at')
        expect(result).to eq(name: 'created_at', direction: :asc)
      end
    end

    context 'with plus sign' do
      it 'returns asc direction' do
        result = described_class.deserialize('+created_at')
        expect(result).to eq(name: 'created_at', direction: :asc)
      end
    end

    context 'with minus sign' do
      it 'returns desc direction' do
        result = described_class.deserialize('-created_at')
        expect(result).to eq(name: 'created_at', direction: :desc)
      end
    end
  end

  describe '.serialize' do
    context 'with asc direction' do
      it 'returns the name without sign' do
        expect(described_class.serialize('created_at', :asc)).to eq 'created_at'
      end
    end

    context 'with desc direction' do
      it 'returns the name with minus sign' do
        expect(described_class.serialize('created_at', :desc)).to eq '-created_at'
      end
    end

    context 'with string direction' do
      it 'converts string to symbol' do
        serialized = %w[asc desc].map do |direction|
          described_class.serialize('created_at', direction)
        end
        expect(serialized).to eq %w[created_at -created_at]
      end
    end

    context 'with invalid direction' do
      it 'raises ArgumentError' do
        expect { described_class.serialize('created_at', :sideways) }
          .to raise_error(ArgumentError, 'direction must be :asc or :desc')
      end

      it 'raises ArgumentError for a direction without symbol conversion' do
        expect { described_class.serialize('created_at', nil) }
          .to raise_error(ArgumentError, 'direction must be :asc or :desc')
      end
    end

    context 'with symbol name' do
      it 'converts to string' do
        serialized = %i[asc desc].map do |direction|
          described_class.serialize(:created_at, direction)
        end
        expect(serialized).to eq %w[created_at -created_at]
      end
    end
  end
end
