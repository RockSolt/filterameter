# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::MatchesFilter do
  let(:filter) { described_class.new(:name, options) }
  let(:query) { filter.apply(Activity.all, 'prepare') }
  let(:options) { Filterameter::Options::PartialOptions.new(true) }

  context 'with partial: true' do
    it 'valid sql' do
      expect { query.explain }.not_to raise_exception
    end

    it 'applies criteria' do
      expect(query.to_sql).to match(/name.*like.*%prepare%/i)
    end

    it 'is valid' do
      expect(filter.valid?(Activity)).to be true
    end
  end

  context 'with from start' do
    let(:options) { Filterameter::Options::PartialOptions.new(:from_start) }

    it 'valid sql' do
      expect { query.explain }.not_to raise_exception
    end

    it 'applies criteria' do
      expect(query.to_sql).to match(/name.*like.*prepare%/i)
      expect(query.to_sql).not_to match(/name.*like.*%prepare%/i)
    end

    it 'is valid' do
      expect(filter.valid?(Activity)).to be true
    end
  end

  context 'with dynamic' do
    let(:options) { Filterameter::Options::PartialOptions.new(:dynamic) }

    it 'valid sql' do
      expect { query.explain }.not_to raise_exception
    end

    it 'applies criteria' do
      expect(query.to_sql).to match(/name.*like.*prepare/i)
      expect(query.to_sql).not_to match(/name.*like.*prepare%/i)
      expect(query.to_sql).not_to match(/name.*like.*%prepare%/i)
    end

    it 'is valid' do
      expect(filter.valid?(Activity)).to be true
    end
  end

  context 'with typo on attribute name' do
    let(:filter) { described_class.new(:namez, options) }

    it 'is not valid' do
      expect(filter.valid?(Activity)).to be false
    end
  end
end
