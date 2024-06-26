# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::FilterDeclaration do
  let(:declaration) { described_class.new(:size, options) }

  context 'with no options' do
    let(:options) { {} }

    it('#parameter_name') { expect(declaration.parameter_name).to eq 'size' }
    it('#name') { expect(declaration.name).to eq 'size' }
    it('#nested?') { expect(declaration.nested?).to be false }
    it('#validations?') { expect(declaration.validations?).to be false }
    it('#partial_match?') { expect(declaration.partial_search?).to be false }
    it('#sortable?') { expect(declaration.sortable?).to be true }
    it('#to_s') { expect(declaration.to_s).to eq 'filter :size' }
  end

  context 'with name specified' do
    let(:options) { { name: :shirt_size } }

    it('#parameter_name') { expect(declaration.parameter_name).to eq 'size' }
    it('#name') { expect(declaration.name).to eq 'shirt_size' }
    it('#to_s') { expect(declaration.to_s).to eq 'filter :size, name: :shirt_size' }
  end

  context 'with association' do
    let(:options) { { association: :one } }

    it('#nested?') { expect(declaration.nested?).to be true }
    it('is an array') { expect(declaration.association).to be_a Array }
    it('#to_s') { expect(declaration.to_s).to eq 'filter :size, association: [:one]' }
  end

  context 'with multi-level association' do
    let(:options) { { association: %i[one two] } }

    it('#nested?') { expect(declaration.nested?).to be true }
    it('is an array') { expect(declaration.association).to be_a Array }
    it('#to_s') { expect(declaration.to_s).to eq 'filter :size, association: [:one, :two]' }
  end

  context 'with partial' do
    let(:options) { { partial: true } }

    it('#partial_match?') { expect(declaration.partial_search?).to be true }
    it('#parital_options') { expect(declaration.partial_options).to be_a(Filterameter::Options::PartialOptions) }
    it('#to_s') { expect(declaration.to_s).to eq 'filter :size, partial: true' }
  end

  context 'with range' do
    let(:options) { { range: true } }

    it('#range_enabled?') { expect(declaration.range_enabled?).to be true }
    it('#range?') { expect(declaration.range?).to be true }
  end

  context 'with range: :min_only' do
    let(:options) { { range: :min_only } }

    it('#range_enabled?') { expect(declaration.range_enabled?).to be true }
    it('#range?') { expect(declaration.range?).to be false }
    it('#min_only?') { expect(declaration.min_only?).to be true }
    it('#minimum_range?') { expect(declaration.minimum_range?).to be false }
  end

  context 'with range: :min_only and range_type: :minimum' do
    let(:declaration) { described_class.new(:size, { range: :min_only }, range_type: :minimum) }

    it('#range_enabled?') { expect(declaration.range_enabled?).to be true }
    it('#range?') { expect(declaration.range?).to be false }
    it('#min_only?') { expect(declaration.min_only?).to be true }
    it('#minimum_range?') { expect(declaration.minimum_range?).to be true }
  end

  context 'with range: :max_only' do
    let(:options) { { range: :max_only } }

    it('#range_enabled?') { expect(declaration.range_enabled?).to be true }
    it('#range?') { expect(declaration.range?).to be false }
    it('#max_only?') { expect(declaration.max_only?).to be true }
    it('#maximum_range?') { expect(declaration.maximum_range?).to be false }
  end

  context 'with range: :max_only and range_type: :maximum' do
    let(:declaration) { described_class.new(:size, { range: :max_only }, range_type: :maximum) }

    it('#range_enabled?') { expect(declaration.range_enabled?).to be true }
    it('#range?') { expect(declaration.range?).to be false }
    it('#max_only?') { expect(declaration.max_only?).to be true }
    it('#maximum_range?') { expect(declaration.maximum_range?).to be true }
  end

  context 'with invalid range' do
    let(:options) { { range: :min } }

    it('raise argument error') { expect { declaration }.to raise_error(ArgumentError) }
  end

  context 'without sort' do
    let(:options) { { sortable: false } }
    it('#sortable?') { expect(declaration.sortable?).to be false }
  end

  context 'with invalid option' do
    let(:options) { { invalid: 12 } }

    it 'raises argument error' do
      expect { declaration }.to raise_error(ArgumentError)
    end
  end
end
