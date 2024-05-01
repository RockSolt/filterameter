# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::FilterFactory do
  let(:factory) { Filterameter::FilterFactory.new(Shirt) }
  let(:filter) { factory.build(declaration) }

  context 'with attribute declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:size, {}) }
    it('is an AttributeFilter') { expect(filter).to be_a Filterameter::Filters::AttributeFilter }
  end

  context 'with scope declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:blue, {}) }
    it('is a ScopeFilter') { expect(filter).to be_a Filterameter::Filters::ScopeFilter }
  end

  context 'with partial declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:color, { partial: true }) }
    it('is a MatchesFilter') { expect(filter).to be_a Filterameter::Filters::MatchesFilter }
  end

  context 'with minimum declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:size_min, { range: :min_only }) }
    it('is a MinimumFilter') { expect(filter).to be_a Filterameter::Filters::MinimumFilter }
  end

  context 'with maximum declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:size_max, { range: :max_only }) }
    it('is a MaximumFilter') { expect(filter).to be_a Filterameter::Filters::MaximumFilter }
  end

  context 'with range declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:size, { range: true }) }
    it('is an AttributeFilter') { expect(filter).to be_a Filterameter::Filters::AttributeFilter }
  end

  context 'with singular association declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:name, { association: :brand }) }
    it('is an NestedFilter') { expect(filter).to be_a Filterameter::Filters::NestedFilter }
  end
end
