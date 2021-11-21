# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::FilterRegistry do
  describe '#add_filter' do
    let(:registry) { described_class.new(instance_spy(Filterameter::FilterFactory)) }

    it 'stores two declarations' do
      registry.add_filter(:color, {})
      registry.add_filter(:size, {})
      expect(registry.filter_names).to contain_exactly('color', 'size')
    end

    it 'adds range filters' do
      registry.add_filter(:date, range: true)
      expect(registry.filter_names).to contain_exactly('date', 'date_min', 'date_max')
    end

    it 'adds min filters' do
      registry.add_filter(:date, range: :min_only)
      expect(registry.filter_names).to contain_exactly('date', 'date_min')
    end

    it 'adds max filters' do
      registry.add_filter(:date, range: :max_only)
      expect(registry.filter_names).to contain_exactly('date', 'date_max')
    end
  end
end
