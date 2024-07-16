# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::QueryBuilder do
  let(:registry) do
    Filterameter::Registries::Registry.new(Activity).tap do |registry|
      registry.add_filter(:name, {})
      registry.add_filter(:completed, {})
      registry.add_filter(:task_count, range: true)
      registry.add_sort(:created_at, {})
    end
  end

  context 'with default query' do
    let(:default_query) { Activity.where(activity_manager_id: 123) }
    let(:instance) { described_class.new(default_query, {}, registry) }
    let(:filter_params) { { name: 'The Activity Name' }.stringify_keys }
    let(:query) { instance.build_query(filter_params, nil) }

    it 'includes default criteria' do
      expect(query.where_values_hash).to include('activity_manager_id' => 123, 'name' => 'The Activity Name')
    end
  end

  context 'with starting query' do
    let(:starting_query) { Activity.where(activity_manager_id: 123) }
    let(:instance) { described_class.new(Activity.all, {}, registry) }
    let(:filter_params) { { name: 'The Activity Name' }.stringify_keys }
    let(:query) { instance.build_query(filter_params, starting_query) }

    it 'includes starting criteria' do
      expect(query.where_values_hash).to include('activity_manager_id' => 123, 'name' => 'The Activity Name')
    end
  end

  context 'with requested sort' do
    let(:instance) { described_class.new(Activity.all, nil, registry) }
    let(:filter_params) { { sort: 'name' }.stringify_keys }
    let(:query) { instance.build_query(filter_params, nil) }

    it 'includes sort' do
      expect(query.order_values).to eq Activity.order(name: :asc).order_values
    end
  end

  context 'when starting query already has sort and no sort requested' do
    let(:instance) { described_class.new(Activity.order(created_at: :desc), { name: :asc }, registry) }
    let(:query) { instance.build_query({}, nil) }

    it 'does not add default' do
      expect(query.order_values.map(&:to_sql))
        .not_to include(*Activity.order(name: :desc).order_values.map(&:to_sql))
    end
  end

  context 'when no sort requested, and no default declared, and starting query does not have a sort' do
    let(:instance) { described_class.new(Activity.all, nil, registry) }
    let(:query) { instance.build_query({}, nil) }

    it 'sorts by primary key desc' do
      expect(query.order_values.map(&:to_sql)).to contain_exactly(*Activity.order(id: :desc).order_values.map(&:to_sql))
    end
  end

  context 'with min and max criteria' do
    let(:default_query) { Activity.where(activity_manager_id: 123) }
    let(:instance) { described_class.new(default_query, {}, registry) }
    let(:filter_params) { { task_count_min: 12, task_count_max: 34 }.stringify_keys }
    let(:query) { instance.build_query(filter_params, nil) }

    it 'includes price range' do
      expect(query.to_sql).to include('"activities"."task_count" BETWEEN 12 AND 34')
    end
  end

  describe 'sort defaulting rules' do
    let(:default_sort) { nil }
    let(:requested_sort) { {} }
    let(:starting_query) { nil }
    let(:instance) { described_class.new(Activity.all, default_sort, registry) }
    let(:query) { instance.build_query(requested_sort, starting_query) }

    context 'when there is a default and a requested sort' do
      let(:default_sort) { [Filterameter::Helpers::RequestedSort.new(:created_at, :desc)] }
      let(:requested_sort) { { sort: '+name' } }

      it 'includes requested sort' do
        expect(query).to sort_by(name: :asc)
      end

      it 'does not add default' do
        expect(query).not_to sort_by(created_at: :desc)
      end
    end

    context 'without a requested sort' do
      context 'when starting query includes a sort' do
        let(:starting_query) { Activity.order(task_count: :desc) }
        let(:default_sort) { [Filterameter::Helpers::RequestedSort.new(:created_at, :desc)] }

        it 'does not add default' do
          expect(query).not_to sort_by(created_at: :desc)
        end

        it 'does not add primary key' do
          expect(query).not_to sort_by(id: :desc)
        end
      end
    end

    context 'with only default sort' do
      let(:default_sort) { [Filterameter::Helpers::RequestedSort.new(:created_at, :desc)] }

      it 'adds default' do
        expect(query).to sort_by(created_at: :desc)
      end

      it 'does not add primary key' do
        expect(query).not_to sort_by(id: :desc)
      end
    end

    context 'without a default' do
      it 'uses primary key' do
        expect(query).to sort_by(id: :desc)
      end
    end
  end

  describe 'undeclared parameters' do
    let(:filter_params) { { name: 'The Activity Name', not_a_filter: 42 }.stringify_keys }
    let(:instance) { described_class.new(Activity.all, {}, registry) }
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
      Filterameter::Registries::Registry.new(Project).tap do |registry|
        registry.add_filter(:priority, validates: { inclusion: { in: Project.priorities } })
        registry.add_filter(:name, {})
      end
    end
    let(:filter_params) { { name: 'The Project Name', priority: 'Very Important' }.stringify_keys }
    let(:query) { described_class.new(Project.all, {}, registry).build_query(filter_params, Project.all) }

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
