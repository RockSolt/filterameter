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
    it('#filter_on_empty?') { expect(declaration.filter_on_empty?).to be false }
    it('#partial_match?') { expect(declaration.partial_search?).to be false }
  end

  context 'with name specified' do
    let(:options) { { name: :shirt_size } }

    it('#parameter_name') { expect(declaration.parameter_name).to eq 'size' }
    it('#name') { expect(declaration.name).to eq 'shirt_size' }
  end

  context 'with association' do
    let(:options) { { association: :brand } }

    it('#nested?') { expect(declaration.nested?).to be true }
    it('is an array') { expect(declaration.association).to be_a Array }
  end

  context 'with multi-level association' do
    let(:options) { { association: %i[brand vendor] } }

    it('#nested?') { expect(declaration.nested?).to be true }
    it('is an array') { expect(declaration.association).to be_a Array }
  end

  context 'with partial' do
    let(:options) { { partial: true } }

    it('#partial_match?') { expect(declaration.partial_search?).to be true }
    it('#parital_options') { expect(declaration.partial_options).to be_a(Filterameter::Options::PartialOptions) }
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
    it('#minimum?') { expect(declaration.minimum?).to be true }
  end

  context 'with range: :max_only' do
    let(:options) { { range: :max_only } }

    it('#range_enabled?') { expect(declaration.range_enabled?).to be true }
    it('#range?') { expect(declaration.range?).to be false }
    it('#maximum?') { expect(declaration.maximum?).to be true }
  end

  context 'with invalid range' do
    let(:options) { { range: :min } }

    it('raise argument error') { expect { declaration }.to raise_error(ArgumentError) }
  end

  context 'with invalid option' do
    let(:options) { { invalid: 12 } }

    it 'raises argument error' do
      expect { declaration }.to raise_error(ArgumentError)
    end
  end
end
