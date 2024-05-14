# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::FilterCoordinator do
  describe 'constructor tries to populate model class from controller name and path' do
    let(:controller_name) { 'my_models' }
    let(:controller_path) { 'foo_bar/my_models' }
    let(:model) { instance_double(Class) }
    let(:result) { described_class.new(controller_name, controller_path).send(:model_class) }

    context 'with model MyModel' do
      before { stub_const('MyModel', model) }

      it { expect(result).to be model }
    end

    context 'with model FooBar::MyModel' do
      before { stub_const('FooBar::MyModel', model) }

      it { expect(result).to be model }
    end

    it 'raises error with no such model' do
      expect { result }.to raise_exception Filterameter::Exceptions::CannotDetermineModelError
    end
  end

  describe '#model_class=' do
    let(:instance) { described_class.new('foo', 'foo/bar') }
    let(:result) { instance.send(:model_class) }

    it 'handles string' do
      instance.model_class = described_class.name
      expect(result).to eq described_class
    end

    it 'handles class' do
      instance.model_class = described_class
      expect(result).to eq described_class
    end
  end

  context 'with starting query' do
    let(:instance) do
      described_class.new('shirts', 'shirts').tap do |cf|
        cf.add_filter(:color, {})
      end
    end
    let(:filter_params) { { color: 'blue' }.stringify_keys }
    let(:starting_query) { Shirt.where(size: 'Medium') }
    let(:query) { instance.build_query(filter_params, starting_query) }

    it 'includes starting criteria' do
      expect(query.where_values_hash).to include('color' => 'blue', 'size' => 'Medium')
    end
  end

  describe 'undeclared parameters' do
    let(:instance) do
      described_class.new('shirts', 'shirts').tap do |cf|
        cf.add_filter(:color, {})
        cf.add_filter(:size, {})
      end
    end
    let(:filter_params) { { color: 'blue', style: 'crew-neck' }.stringify_keys }
    let(:starting_query) { nil }
    let(:query) { instance.build_query(filter_params, starting_query) }

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
        expect { instance.build_query(filter_params, nil) }
          .to raise_error(Filterameter::Exceptions::UndeclaredParameterError,
                          'The following filter parameter has not been declared: style')
      end
    end
  end

  describe 'validation failure' do
    let(:instance) do
      described_class.new('shirts', 'shirts').tap do |cf|
        cf.add_filter(:color, {})
        cf.add_filter(:size, validates: { inclusion: { in: %w[Small Medium Large] } })
      end
    end
    let(:filter_params) { { color: 'blue', size: 'Extra Large' }.stringify_keys }
    let(:query) { instance.build_query(filter_params, nil) }

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
