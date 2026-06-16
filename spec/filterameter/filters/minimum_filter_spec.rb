# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::MinimumFilter do
  let(:filter) { described_class.new(Activity, :task_count) }
  let(:query) { filter.apply(Activity.all, 42) }

  it 'valid sql' do
    expect { query.explain }.not_to raise_exception
  end

  it 'applies criteria' do
    expect(query.to_sql).to include '"activities"."task_count" >= 42'
  end

  it 'is valid' do
    expect(filter.valid?(Activity)).to be true
  end

  context 'with typo on attribute name' do
    let(:filter) { described_class.new(Activity, :namez) }

    it 'is not valid' do
      expect(filter.valid?(Activity)).to be false
    end
  end

  context 'with converter' do
    let(:filter) { described_class.new(Activity, :task_count) { |v| v.is_a?(String) ? v.delete(',') : v } }
    let(:query) { filter.apply(Activity.all, '1,234') }

    it 'converts value' do
      expect(query.to_sql).to include '>= 1234'
    end
  end
end
