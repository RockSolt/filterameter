# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Sorts::ScopeSort do
  let(:sort) { described_class.new(:by_task_count) }
  let(:query) { class_spy('Activity') }

  it 'applies sort to query' do
    sort.apply(query, :asc)
    expect(query).to have_received(:by_task_count).with(:asc)
  end

  it 'is valid with valid scope' do
    sort = described_class.new(:by_task_count)
    expect(sort.valid?(Activity)).to be true
  end

  context 'with a scope that is not a sort' do
    let(:sort) { described_class.new(:not_a_scope) }

    it 'is not valid' do
      expect(sort.valid?(Activity)).to be false
    end

    it 'reports error' do
      sort.valid?(Activity)
      expect(sort.errors).to contain_exactly "Activity class method 'not_a_scope' is not a scope"
    end
  end

  context 'with inline sort with no arguments' do
    let(:sort) { described_class.new(:inline_sort_scope_with_no_args) }

    it 'is not valid' do
      expect(sort.valid?(Activity)).to be false
    end

    it 'reports errors' do
      sort.valid?(Activity)
      expect(sort.errors)
        .to contain_exactly "Activity scope 'inline_sort_scope_with_no_args' must take exactly one argument to sort by"
    end
  end

  context 'with class method with no aguments' do
    let(:sort) { described_class.new(:sort_scope_with_no_args) }

    it 'is not valid' do
      expect(sort.valid?(Activity)).to be false
    end

    it 'reports errors' do
      sort.valid?(Activity)
      expect(sort.errors)
        .to contain_exactly "Activity scope 'sort_scope_with_no_args' must take exactly one argument to sort by"
    end
  end

  context 'with class method with two arguments' do
    let(:sort) { described_class.new(:sort_scope_with_two_args) }

    it 'is not valid' do
      expect(sort.valid?(Activity)).to be false
    end

    it 'reports errors' do
      sort.valid?(Activity)
      expect(sort.errors)
        .to contain_exactly "Activity scope 'sort_scope_with_two_args' must take exactly one argument to sort by"
    end
  end
end
