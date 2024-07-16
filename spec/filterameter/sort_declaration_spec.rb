# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::SortDeclaration do
  let(:declaration) { described_class.new(:size, options) }

  context 'with no options' do
    let(:options) { {} }

    it('#parameter_name') { expect(declaration.parameter_name).to eq 'size' }
    it('#name') { expect(declaration.name).to eq 'size' }
    it('#nested?') { expect(declaration.nested?).to be false }
    it('#to_s') { expect(declaration.to_s).to eq 'sort :size' }
  end

  context 'with name specified' do
    let(:options) { { name: :shirt_size } }

    it('#parameter_name') { expect(declaration.parameter_name).to eq 'size' }
    it('#name') { expect(declaration.name).to eq 'shirt_size' }
    it('#to_s') { expect(declaration.to_s).to eq 'sort :size, name: :shirt_size' }
  end

  context 'with association' do
    let(:options) { { association: :one } }

    it('#nested?') { expect(declaration.nested?).to be true }
    it('is an array') { expect(declaration.association).to be_a Array }
    it('#to_s') { expect(declaration.to_s).to eq 'sort :size, association: [:one]' }
  end

  context 'with multi-level association' do
    let(:options) { { association: %i[one two] } }

    it('#nested?') { expect(declaration.nested?).to be true }
    it('is an array') { expect(declaration.association).to be_a Array }
    it('#to_s') { expect(declaration.to_s).to eq 'sort :size, association: [:one, :two]' }
  end

  context 'with invalid option' do
    let(:options) { { invalid: 12 } }

    it 'raises argument error' do
      expect { declaration }.to raise_error(ArgumentError)
    end
  end
end
