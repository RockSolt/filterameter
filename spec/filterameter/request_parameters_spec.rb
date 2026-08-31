# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::RequestParameters do
  let(:params) do
    {
      filter: { status: 'active', values: { name: 'example' }, sort: ['name', '-created_at'] },
      page: { number: '3', size: '25' },
      ignored: 'value'
    }
  end

  let(:request_parameters) { described_class.new(params) }

  after { Filterameter.reset }

  before do
    request_parameters.filter_params[:values][:name] = 'changed'
    request_parameters.sort_params << 'updated_at'
    request_parameters.filter_sort_and_pagination_params[:page][:number] = '4'
  end

  it 'returns an independent copy of filter params' do
    expect(request_parameters.filter_params).to eq(status: 'active', values: { name: 'example' })
  end

  it 'returns an independent copy of sort params' do
    expect(request_parameters.sort_params).to eq(['name', '-created_at'])
  end

  it 'returns an independent copy of all params' do
    expect(request_parameters.filter_sort_and_pagination_params).to eq(
      filter: { status: 'active', values: { name: 'example' }, sort: ['name', '-created_at'] },
      page: { number: '3', size: '25' }
    )
  end

  it 'returns an immutable page path' do
    expect(request_parameters.pagination_page_path).to be_frozen
  end

  it 'returns an immutable size path' do
    expect(request_parameters.pagination_size_path).to be_frozen
  end

  it 'does not freeze the configured paths' do
    expect(Filterameter.configuration.pagination_page_param).not_to be_frozen
  end
end
