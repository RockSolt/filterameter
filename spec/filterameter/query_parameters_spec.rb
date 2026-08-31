# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::QueryParameters do
  subject(:query_parameters) { described_class.new(params, default_sort:) }

  let(:params) do
    ActionController::Parameters.new(
      filter: { status: 'active', sort: '-created_at' },
      page: { number: '3' },
      ignored: 'value'
    )
  end
  let(:default_sort) { { name: :asc } }

  after { Filterameter.reset }

  it 'extracts filters separately from the requested sort' do
    expect(query_parameters.filter_params).to eq(status: 'active')
  end

  it 'exposes the requested sort' do
    expect(query_parameters.sort_order).to eq(created_at: :desc)
  end

  it 'uses the supplied default when a sort was not requested' do
    params[:filter].delete(:sort)

    expect(query_parameters.sort_order).to eq(name: :asc)
  end

  it 'tracks whether the effective sort was explicitly requested' do
    params[:filter].delete(:sort)

    expect(query_parameters.sort_requested?).to be false
    expect(query_parameters.requested_sort_order).to eq({})
  end

  it 'normalizes string keys and directions for direct callers' do
    params[:filter].delete(:sort)
    query_parameters = described_class.new(params, default_sort: { 'created_at' => 'desc' })

    expect(query_parameters.sort_order).to eq(created_at: :desc)
  end

  it 'supports multiple default sorts in declaration order' do
    params[:filter].delete(:sort)
    query_parameters = described_class.new(params, default_sort: { created_at: :desc, name: :asc })

    expect(query_parameters.sort_order).to eq(created_at: :desc, name: :asc)
  end

  it 'rejects defaults that do not use the declaration hash format' do
    expect { described_class.new(params, default_sort: '-name') }
      .to raise_error(ArgumentError, 'default_sort must be a hash of sort names and directions')
  end

  describe '#for_page' do
    it 'preserves the Filterameter query state and replaces the page number' do
      expect(query_parameters.for_page(4)).to eq(
        filter: { status: 'active', sort: '-created_at' },
        page: { number: 4 }
      )
    end
  end

  describe '#for_size' do
    it 'preserves the Filterameter query state, removes the page number, and replaces the page size' do
      expect(query_parameters.for_size(50)).to eq(
        filter: { status: 'active', sort: '-created_at' },
        page: { size: 50 }
      )
    end
  end

  describe '#for_sort' do
    it 'uses Filterameter ascending sort syntax and omits the page parameter' do
      expect(query_parameters.for_sort(:name)).to eq(filter: { status: 'active', sort: 'name' })
    end

    it 'uses Filterameter descending sort syntax' do
      expect(query_parameters.for_sort(:name,
                                       initial_direction: :desc)).to eq(filter: { status: 'active', sort: '-name' })
    end

    it 'rejects directions that Filterameter does not support' do
      expect { query_parameters.for_sort(:name, initial_direction: :sideways) }
        .to raise_error(ArgumentError, 'direction must be :asc or :desc')
    end

    it 'changes a matching ascending default to descending' do
      params[:filter].delete(:sort)
      query_parameters = described_class.new(params, default_sort: { name: :asc })

      expect(query_parameters.for_sort(:name, initial_direction: :asc)).to eq(
        filter: { status: 'active', sort: '-name' }
      )
    end

    it 'changes a matching descending default to ascending instead of omitting sort' do
      params[:filter].delete(:sort)
      query_parameters = described_class.new(params, default_sort: { name: :desc })

      expect(query_parameters.for_sort(:name, initial_direction: :asc)).to eq(
        filter: { status: 'active', sort: 'name' }
      )
    end

    it 'does not omit an explicit sort when it matches the default' do
      params[:filter][:sort] = '-name'
      query_parameters = described_class.new(params, default_sort: { name: :desc })

      expect(query_parameters.for_sort(:name, initial_direction: :asc)).to eq(
        filter: { status: 'active', sort: 'name' }
      )
    end

    context 'when the strategy returns multiple fields' do
      subject(:query_parameters) do
        strategy = ->(_query_params, _name, _dir) { { name: :asc, created_at: :desc } }
        described_class.new(params, sort_strategy: strategy)
      end

      it 'serializes as an array' do
        expect(query_parameters.for_sort(:name)).to eq(filter: { status: 'active', sort: %w[name -created_at] })
      end
    end

    context 'when the strategy returns an empty hash' do
      subject(:query_parameters) do
        strategy = ->(_query_params, _name, _dir) { {} }
        described_class.new(params, sort_strategy: strategy)
      end

      it 'removes the sort key from the parameters' do
        expect(query_parameters.for_sort(:name)).to eq(filter: { status: 'active' })
      end
    end

    context 'when the strategy returns an invalid direction' do
      subject(:query_parameters) do
        strategy = ->(_query_params, _name, _dir) { { name: :sideways } }
        described_class.new(params, sort_strategy: strategy)
      end

      it 'rejects the direction regardless of what the strategy returns' do
        expect { query_parameters.for_sort(:name) }
          .to raise_error(ArgumentError, 'direction must be :asc or :desc')
      end
    end
  end

  describe '#sorted_by?' do
    it 'returns true when the current sort matches the name' do
      expect(query_parameters.sorted_by?(:created_at)).to be true
    end

    it 'returns false when the current sort does not match the name' do
      expect(query_parameters.sorted_by?(:name)).to be false
    end

    context 'with multiple sorts' do
      let(:params) { ActionController::Parameters.new(filter: { status: 'active', sort: %w[name -created_at] }) }

      it 'returns true for ascending sort' do
        expect(query_parameters.sorted_by?(:name)).to be true
      end

      it 'returns true for descending sort' do
        expect(query_parameters.sorted_by?(:created_at)).to be true
      end
    end
  end

  describe '#sort_direction' do
    it 'returns nil when field not sorted' do
      expect(query_parameters.sort_direction(:name)).to be_nil
    end

    it 'returns :desc when field sorted descending' do
      expect(query_parameters.sort_direction(:created_at)).to eq :desc
    end

    context 'with multiple sorts' do
      let(:params) { ActionController::Parameters.new(filter: { status: 'active', sort: %w[name -created_at] }) }

      it 'returns nil when field not sorted' do
        expect(query_parameters.sort_direction(:status)).to be_nil
      end

      it 'returns :asc for ascending sort' do
        expect(query_parameters.sort_direction(:name)).to eq :asc
      end

      it 'returns :desc for descending sort' do
        expect(query_parameters.sort_direction(:created_at)).to eq :desc
      end
    end
  end

  context 'with nested pagination parameters' do
    let(:params) do
      ActionController::Parameters.new(
        filter: { status: 'active', sort: '-created_at' },
        page: { number: '3', size: '50' }
      )
    end

    it 'preserves the page size when replacing the page number' do
      expect(query_parameters.for_page(4)).to eq(
        filter: { status: 'active', sort: '-created_at' },
        page: { number: 4, size: '50' }
      )
    end

    it 'preserves the page size and omits the page number for a sort' do
      expect(query_parameters.for_sort(:name)).to eq(
        filter: { status: 'active', sort: 'name' },
        page: { size: '50' }
      )
    end
  end

  context 'with top-level pagination parameters' do
    before do
      Filterameter.configuration.pagination_page_param = [:page]
      Filterameter.configuration.pagination_size_param = [:per_page]
    end

    let(:params) do
      ActionController::Parameters.new(
        filter: { status: 'active', sort: '-created_at' }, page: '3', per_page: '50'
      )
    end

    it 'uses the configured page parameter and preserves the page size' do
      expect(query_parameters.for_page(4)).to eq(
        filter: { status: 'active', sort: '-created_at' }, page: 4, per_page: '50'
      )
    end

    it 'omits the page number when changing the size' do
      expect(query_parameters.for_size(100)).to eq(
        filter: { status: 'active', sort: '-created_at' }, per_page: 100
      )
    end

    it 'omits the configured page parameter when building a sort link' do
      expect(query_parameters.for_sort(:name)).to eq(
        filter: { status: 'active', sort: 'name' }, per_page: '50'
      )
    end
  end

  context 'with a custom filter key' do
    before { Filterameter.configuration.filter_key = :criteria }

    let(:default_sort) { nil }
    let(:params) do
      ActionController::Parameters.new(criteria: { status: 'active' }, page: { number: '3' })
    end

    it 'uses the configured key when building links' do
      expect(query_parameters.for_sort(:name, initial_direction: :desc)).to eq(
        criteria: { status: 'active', sort: '-name' }
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
      expect(query_parameters.for_sort(:name)).to eq(status: 'active', sort: 'name')
    end
  end
end
