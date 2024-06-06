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
end
