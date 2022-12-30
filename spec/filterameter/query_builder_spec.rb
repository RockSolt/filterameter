# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::QueryBuilder do
  let(:registry) do
    Filterameter::FilterRegistry.new(Filterameter::FilterFactory.new(Shirt)).tap do |registry|
      registry.add_filter(:size, {})
      registry.add_filter(:color, {})
      registry.add_filter(:price, name: :current, association: :price, range: true)
    end
  end

  context 'with default query' do
    let(:default_query) { Shirt.where(size: 'Medium') }
    let(:instance) { described_class.new(default_query, registry) }
    let(:filter_params) { { color: 'gold' }.stringify_keys }
    let(:query) { instance.build_query(filter_params, nil) }

    it 'includes default criteria' do
      expect(query.where_values_hash).to include('color' => 'gold', 'size' => 'Medium')
    end
  end

  context 'with starting query' do
    let(:starting_query) { Shirt.where(size: 'Medium') }
    let(:instance) { described_class.new(nil, registry) }
    let(:filter_params) { { color: 'blue' }.stringify_keys }
    let(:query) { instance.build_query(filter_params, starting_query) }

    it 'includes starting criteria' do
      expect(query.where_values_hash).to include('color' => 'blue', 'size' => 'Medium')
    end
  end

  context 'with min and max prices' do
    let(:default_query) { Shirt.where(size: 'Medium') }
    let(:instance) { described_class.new(default_query, registry) }
    let(:filter_params) { { price_min: 12.34, price_max: 34.56 }.stringify_keys }
    let(:query) { instance.build_query(filter_params, nil) }

    it 'includes price range' do
      expect(query.to_sql).to include('"prices"."current" BETWEEN 12.34 AND 34.56')
    end
  end

  context 'with min and max params' do
    let(:registry) do
      Filterameter::FilterRegistry.new(Filterameter::FilterFactory.new(Shirt)).tap do |registry|
        registry.add_filter(:price, { range: true })
      end
    end
    let(:price_filter) { instance_spy(Filterameter::Filters::AttributeFilter) }

    it 'passes range to price filter' do
      allow(registry).to receive(:fetch).and_return(price_filter)

      builder = described_class.new(Shirt.all, registry)
      builder.build_query({ price_min: 12.34, price_max: 23.45 })
      expect(price_filter).to have_received(:apply).once.with(anything, instance_of(Range))
    end
  end

  describe 'undeclared parameters' do
    let(:filter_params) { { color: 'blue', style: 'crew-neck' }.stringify_keys }
    let(:instance) { described_class.new(nil, registry) }
    let(:query) { instance.build_query(filter_params, Shirt.all) }

    before { allow(Filterameter.configuration).to receive(:action_on_undeclared_parameters).and_return(action) }

    context 'with no action' do
      let(:action) { false }

      it 'builds query with valid parameter' do
        expect(query.where_values_hash).to match('color' => 'blue')
      end
    end

    context 'with action log' do
      let(:action) { :log }
      let(:subscriber) { Filterameter::LogSubscriber.new }

      before do
        allow(subscriber).to receive(:undeclared_parameters)
        Filterameter::LogSubscriber.attach_to :filterameter, subscriber
      end

      it 'builds query with valid parameter' do
        expect(query.where_values_hash).to match('color' => 'blue')
      end

      it 'notifies subscriber for undeclared_parameters.filterameter' do
        query
        expect(subscriber).to have_received(:undeclared_parameters)
      end
    end

    context 'with action raise' do
      let(:action) { :raise }

      it 'raises exception' do
        expect { instance.build_query(filter_params, Shirt.all) }
          .to raise_error(Filterameter::Exceptions::UndeclaredParameterError)
      end
    end
  end

  describe 'validation failure' do
    let(:registry) do
      Filterameter::FilterRegistry.new(Filterameter::FilterFactory.new(Shirt)).tap do |registry|
        registry.add_filter(:size, validates: { inclusion: { in: %w[Small Medium Large] } })
        registry.add_filter(:color, {})
      end
    end
    let(:instance) { described_class.new(nil, registry) }
    let(:filter_params) { { color: 'blue', size: 'Extra Large' }.stringify_keys }
    let(:query) { described_class.new(nil, registry).build_query(filter_params, Shirt.all) }

    before { allow(Filterameter.configuration).to receive(:action_on_validation_failure).and_return(action) }

    context 'with no action' do
      let(:action) { false }

      it 'builds query with valid parameter' do
        expect(query.where_values_hash).to match('color' => 'blue')
      end
    end

    context 'with action log' do
      let(:action) { :log }
      let(:subscriber) { Filterameter::LogSubscriber.new }

      before do
        allow(subscriber).to receive(:validation_failure)
        Filterameter::LogSubscriber.attach_to :filterameter, subscriber
      end

      it 'builds query with valid parameter' do
        expect(query.where_values_hash).to match('color' => 'blue')
      end

      it 'notifies subscriber for undeclared_parameters.filterameter' do
        query
        expect(subscriber).to have_received(:validation_failure)
      end
    end

    context 'with action raise' do
      let(:action) { :raise }

      it 'raises exception' do
        expect { instance.build_query(filter_params, nil) }
          .to raise_error(Filterameter::Exceptions::ValidationError,
                          'The following parameter(s) failed validation: ["Size is not included in the list"]')
      end
    end
  end
end
