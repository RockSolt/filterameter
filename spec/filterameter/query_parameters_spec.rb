# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::QueryParameters do
  subject(:query_parameters) { described_class.build(params, default_sort:) }

  let(:params) do
    ActionController::Parameters.new(
      filter: { status: 'active', sort: '-created_at' },
      page: { number: '3' },
      ignored: 'value'
    )
  end
  let(:default_sort) { { name: :asc } }

  after { Filterameter.reset }

  describe '.build' do
    it 'extracts filters separately from the requested sort' do
      expect(query_parameters.filter_params).to eq(status: 'active')
    end

    it 'exposes the requested sort' do
      expect(query_parameters.sort).to eq('-created_at')
    end

    it 'uses the supplied default when a sort was not requested' do
      params[:filter].delete(:sort)

      expect(query_parameters.sort).to eq('name')
    end

    it 'supports multiple default sorts in declaration order' do
      params[:filter].delete(:sort)
      query_parameters = described_class.build(params, default_sort: { created_at: :desc, name: :asc })

      expect(query_parameters.sort).to eq(%w[-created_at name])
    end

    it 'rejects defaults that do not use the declaration hash format' do
      expect { described_class.build(params, default_sort: '-name') }
        .to raise_error(ArgumentError, 'default_sort must be a hash of sort names and directions')
    end
  end

  describe '#for_page' do
    it 'preserves the Filterameter query state and replaces the page number' do
      expect(query_parameters.for_page(4)).to eq(
        filter: { status: 'active', sort: '-created_at' },
        page: { number: 4 }
      )
    end
  end

  describe '#for_sort' do
    it 'uses Filterameter ascending sort syntax and resets the page' do
      expect(query_parameters.for_sort(:name)).to eq(
        filter: { status: 'active', sort: 'name' },
        page: { number: 1 }
      )
    end

    it 'uses Filterameter descending sort syntax' do
      expect(query_parameters.for_sort(:name, direction: :desc)).to eq(
        filter: { status: 'active', sort: '-name' },
        page: { number: 1 }
      )
    end

    it 'rejects directions that Filterameter does not support' do
      expect { query_parameters.for_sort(:name, direction: :sideways) }
        .to raise_error(ArgumentError, 'direction must be :asc or :desc')
    end
  end

  context 'with a custom filter key' do
    before { Filterameter.configuration.filter_key = :criteria }

    let(:params) do
      ActionController::Parameters.new(criteria: { status: 'active' }, page: { number: '3' })
    end

    it 'uses the configured key when building links' do
      expect(query_parameters.for_sort(:name, direction: :desc)).to eq(
        criteria: { status: 'active', sort: '-name' },
        page: { number: 1 }
      )
    end
  end

  context 'without a filter key' do
    before { Filterameter.configuration.filter_key = false }

    let(:params) do
      ActionController::Parameters.new(status: 'active', sort: '-created_at', page: { number: '3' })
    end

    it 'uses top-level parameters when building page links' do
      expect(query_parameters.for_page(4)).to eq(status: 'active', sort: '-created_at', page: { number: 4 })
    end

    it 'uses top-level parameters when building sort links' do
      expect(query_parameters.for_sort(:name)).to eq(status: 'active', sort: 'name', page: { number: 1 })
    end
  end
end
