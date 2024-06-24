# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Registries::Registry do
  let(:registry) { described_class.new(nil) }

  context 'when filter is sortable (default)' do
    before { registry.add_filter(:size, {}) }

    it('adds sort') { expect { registry.fetch_sort(:size) }.not_to raise_exception }
  end

  context 'when filter is not sortable' do
    before { registry.add_filter(:size, { sortable: false }) }

    it 'adds sort' do
      expect { registry.fetch_sort(:size) }.to raise_exception(Filterameter::Exceptions::UndeclaredParameterError)
    end
  end
end
