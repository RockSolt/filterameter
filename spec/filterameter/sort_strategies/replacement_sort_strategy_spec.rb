# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::SortStrategies::ReplacementSortStrategy do
  let(:strategy) { described_class.new }

  let(:query_parameters) { Filterameter::QueryParameters.new(params, default_sort:) }
  let(:params) do
    ActionController::Parameters.new(
      filter: { status: 'active', sort: '-created_at' },
      page: { number: '3' },
      ignored: 'value'
    )
  end
  let(:default_sort) { { name: :asc } }

  it 'replaces the current sort with the requested sort' do
    result = strategy.call(query_parameters, 'name', :asc)
    expect(result).to eq({ 'name' => :asc })
  end

  it 'toggles the direction if the field is currently being sorted in the initial direction' do
    result = strategy.call(query_parameters, 'created_at', :desc)
    expect(result).to eq({ 'created_at' => :asc })
  end

  it 'removes the sort if the field is currently being sorted in the opposite direction' do
    result = strategy.call(query_parameters, 'created_at', :asc)
    expect(result).to eq({})
  end
end
