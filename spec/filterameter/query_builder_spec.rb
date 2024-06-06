# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::QueryBuilder do
  let(:registry) do
    Filterameter::FilterRegistry.new(Filterameter::FilterFactory.new(Activity)).tap do |registry|
      registry.add_filter(:name, {})
      registry.add_filter(:completed, {})
      registry.add_filter(:task_count, range: true)
    end
  end

  context 'with default query' do
    let(:default_query) { Activity.where(activity_manager_id: 123) }
    let(:instance) { described_class.new(default_query, registry) }
    let(:filter_params) { { name: 'The Activity Name' }.stringify_keys }
    let(:query) { instance.build_query(filter_params, nil) }

    it 'includes default criteria' do
      expect(query.where_values_hash).to include('activity_manager_id' => 123, 'name' => 'The Activity Name')
    end
  end

  context 'with starting query' do
    let(:starting_query) { Activity.where(activity_manager_id: 123) }
    let(:instance) { described_class.new(nil, registry) }
    let(:filter_params) { { name: 'The Activity Name' }.stringify_keys }
    let(:query) { instance.build_query(filter_params, starting_query) }

    it 'includes starting criteria' do
      expect(query.where_values_hash).to include('activity_manager_id' => 123, 'name' => 'The Activity Name')
    end
  end

  context 'with min and max criteria' do
    let(:default_query) { Activity.where(activity_manager_id: 123) }
    let(:instance) { described_class.new(default_query, registry) }
    let(:filter_params) { { task_count_min: 12, task_count_max: 34 }.stringify_keys }
    let(:query) { instance.build_query(filter_params, nil) }

    it 'includes price range' do
      expect(query.to_sql).to include('"activities"."task_count" BETWEEN 12 AND 34')
    end
  end

  describe 'undeclared parameters' do
    let(:filter_params) { { name: 'The Activity Name', not_a_filter: 42 }.stringify_keys }
    let(:instance) { described_class.new(nil, registry) }
    let(:query) { instance.build_query(filter_params, Activity.all) }

    before { allow(Filterameter.configuration).to receive(:action_on_undeclared_parameters).and_return(action) }

    context 'with no action' do
      let(:action) { false }

      it 'builds query with valid parameter' do
        expect(query.where_values_hash).to match('name' => 'The Activity Name')
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
        expect(query.where_values_hash).to match('name' => 'The Activity Name')
      end

      it 'notifies subscriber for undeclared_parameters.filterameter' do
        query
        expect(subscriber).to have_received(:undeclared_parameters)
      end
    end

    context 'with action raise' do
      let(:action) { :raise }

      it 'raises exception' do
        expect { query }.to raise_error(Filterameter::Exceptions::UndeclaredParameterError)
      end
    end
  end

  describe 'validation failure' do
    let(:registry) do
      Filterameter::FilterRegistry.new(Filterameter::FilterFactory.new(Project)).tap do |registry|
        registry.add_filter(:priority, validates: { inclusion: { in: Project.priorities } })
        registry.add_filter(:name, {})
      end
    end
    let(:instance) { described_class.new(nil, registry) }
    let(:filter_params) { { name: 'The Project Name', priority: 'Very Important' }.stringify_keys }
    let(:query) { described_class.new(nil, registry).build_query(filter_params, Project.all) }

    before { allow(Filterameter.configuration).to receive(:action_on_validation_failure).and_return(action) }

    context 'with no action' do
      let(:action) { false }

      it 'builds query with valid parameter' do
        expect(query.where_values_hash).to match('name' => 'The Project Name')
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
        expect(query.where_values_hash).to match('name' => 'The Project Name')
      end

      it 'notifies subscriber for undeclared_parameters.filterameter' do
        query
        expect(subscriber).to have_received(:validation_failure)
      end
    end

    context 'with action raise' do
      let(:action) { :raise }

      it 'raises exception' do
        expect { query }.to raise_error(
          Filterameter::Exceptions::ValidationError,
          'The following parameter(s) failed validation: ["Priority is not included in the list"]'
        )
      end
    end
  end
end
