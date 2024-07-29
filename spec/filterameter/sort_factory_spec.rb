# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::SortFactory do
  let(:factory) { described_class.new(Project) }
  let(:sort) { factory.build(declaration) }

  context 'with attribute declaration' do
    let(:declaration) { Filterameter::SortDeclaration.new(:name, {}) }

    it('is an AttributeSort') { expect(sort).to be_a Filterameter::Sorts::AttributeSort }
  end

  context 'with scope declaration' do
    let(:declaration) { Filterameter::SortDeclaration.new(:by_created_at, {}) }

    it('is a ScopeFilter') { expect(sort).to be_a Filterameter::Filters::ScopeFilter }
  end

  context 'with singular association declaration' do
    let(:factory) { described_class.new(Activity) }
    let(:declaration) { Filterameter::SortDeclaration.new(:name, { association: :project }) }

    it('is an NestedFilter') { expect(sort).to be_a Filterameter::Filters::NestedFilter }
  end

  context 'with collection association declaration' do
    let(:declaration) { Filterameter::SortDeclaration.new(:name, { association: :activities }) }

    it 'raises exception' do
      expect { sort }.to raise_exception Filterameter::Exceptions::CollectionAssociationSortError
    end
  end
end
