# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::FilterFactory do
  let(:factory) { Filterameter::FilterFactory.new(Project) }
  let(:filter) { factory.build(declaration) }

  context 'with attribute declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:name, {}) }
    it('is an AttributeFilter') { expect(filter).to be_a Filterameter::Filters::AttributeFilter }
  end

  context 'with scope declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:in_progress, {}) }
    it('is a ScopeFilter') { expect(filter).to be_a Filterameter::Filters::ScopeFilter }
  end

  context 'with conditional scope declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:high_priority, {}) }
    it('is a ConditionalScopeFilter') { expect(filter).to be_a Filterameter::Filters::ConditionalScopeFilter }
  end

  context 'with a multi-argument scope declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:multi_arg_scope, {}) }
    it('raises FilterScopeArgumentError') do
      expect { filter }.to raise_error(Filterameter::DeclarationErrors::FilterScopeArgumentError)
    end
  end

  context 'with partial declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:name, { partial: true }) }
    it('is a MatchesFilter') { expect(filter).to be_a Filterameter::Filters::MatchesFilter }
  end

  context 'with minimum declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:priority_min, { range: :min_only }, range_type: :minimum) }
    it('is a MinimumFilter') { expect(filter).to be_a Filterameter::Filters::MinimumFilter }
  end

  context 'with maximum declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:priority_max, { range: :max_only }, range_type: :maximum) }
    it('is a MaximumFilter') { expect(filter).to be_a Filterameter::Filters::MaximumFilter }
  end

  context 'with range declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:priority, { range: true }) }
    it('is an AttributeFilter') { expect(filter).to be_a Filterameter::Filters::AttributeFilter }
  end

  context 'with singular association declaration' do
    let(:factory) { Filterameter::FilterFactory.new(Activity) }
    let(:declaration) { Filterameter::FilterDeclaration.new(:name, { association: :project }) }
    it('is an NestedFilter') { expect(filter).to be_a Filterameter::Filters::NestedFilter }
  end

  context 'with collection association declaration' do
    let(:declaration) { Filterameter::FilterDeclaration.new(:name, { association: :activities }) }
    it('is an NestedCollectionFilter') { expect(filter).to be_a Filterameter::Filters::NestedCollectionFilter }
  end
end
