# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Registries::FilterRegistry do
  describe '#add' do
    let(:registry) { described_class.new(Filterameter::FilterFactory.new(Project)) }
    let(:filter_names) { registry.filter_declarations.map(&:parameter_name) }

    it 'stores two declarations' do
      registry.add(:color, {})
      registry.add(:size, {})
      expect(filter_names).to contain_exactly('color', 'size')
    end

    it 'adds range filters' do
      registry.add(:date, range: true)
      expect(filter_names).to contain_exactly('date', 'date_min', 'date_max')
    end

    it 'stores ranges filters with correct name' do
      registry.add(:date, range: true)
      expect(registry.filter_declarations.map(&:name).uniq).to contain_exactly('date')
    end

    context 'with min-only range' do
      before { registry.add(:date, range: :min_only) }

      it 'adds min filters' do
        expect(filter_names).to contain_exactly('date', 'date_min')
      end

      it 'builds attribute filter' do
        expect(registry.fetch('date')).to be_a Filterameter::Filters::AttributeFilter
      end

      it 'builds minimum filter' do
        expect(registry.fetch('date_min')).to be_a Filterameter::Filters::MinimumFilter
      end
    end

    context 'with max-only range' do
      before { registry.add(:date, range: :max_only) }

      it 'adds max filters' do
        expect(filter_names).to contain_exactly('date', 'date_max')
      end

      it 'builds attribute filter' do
        expect(registry.fetch('date')).to be_a Filterameter::Filters::AttributeFilter
      end

      it 'builds maximum filter' do
        expect(registry.fetch('date_max')).to be_a Filterameter::Filters::MaximumFilter
      end
    end

    context 'with name specified for range filter' do
      before { registry.add(:date, name: :start_date, range: true) }

      it 'adds range filters' do
        expect(filter_names).to contain_exactly('date', 'date_min', 'date_max')
      end

      it 'stores ranges filters with correct attribute name' do
        expect(registry.filter_declarations.map(&:name).uniq).to contain_exactly('start_date')
      end
    end
  end

  describe '#fetch' do
    let(:factory) { instance_spy(Filterameter::FilterFactory) }
    let(:registry) { described_class.new(factory).tap { |r| r.add(:color, {}) } }

    describe 'builds filter from factory' do
      it 'works with string' do
        registry.fetch('color')
        expect(factory).to have_received(:build)
      end

      it 'works with symbol' do
        registry.fetch(:color)
        expect(factory).to have_received(:build)
      end
    end

    it 'raises undeclared parameter error' do
      expect { registry.fetch(:foo) }.to raise_exception Filterameter::Exceptions::UndeclaredParameterError,
                                                         'The following filter parameter has not been declared: foo'
    end
  end
end
