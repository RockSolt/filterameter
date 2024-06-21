# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::NestedFilter do
  let(:filter) { described_class.new([:activity], Activity, Filterameter::Filters::AttributeFilter.new(:name)) }
  let(:query) { filter.apply(Task.all, 'The Activity Name') }

  it 'includes joins' do
    expect(query.joins_values).to contain_exactly(:activity)
  end

  it 'applies nested filter' do
    expect(query.where_values_hash('activities')).to match('name' => 'The Activity Name')
  end

  describe 'multi-level associations' do
    context 'with attribute filter' do
      let(:filter) do
        described_class.new(%i[activity project], Project, Filterameter::Filters::AttributeFilter.new(:priority))
      end
      let(:query) { filter.apply(Task.all, 'high') }

      it 'includes builds nested hash for joins' do
        expect(query.joins_values).to contain_exactly({ activity: { project: {} } })
      end

      it 'generates valid sql' do
        expect { query.explain }.not_to raise_exception
      end
    end

    context 'with scope filter' do
      let(:filter) do
        described_class.new(%i[activities tasks], Task, Filterameter::Filters::ConditionalScopeFilter.new(:incomplete))
      end
      let(:query) { filter.apply(Project.all, true) }

      it 'includes builds nested hash for joins' do
        expect(query.joins_values).to contain_exactly({ activities: { tasks: {} } })
      end

      it 'generates valid sql' do
        expect { query.explain }.not_to raise_exception
      end
    end
  end
end
