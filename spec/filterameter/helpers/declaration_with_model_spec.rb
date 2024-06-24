# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Helpers::DeclarationWithModel do
  describe '#scope?' do
    let(:inspector) { described_class.new(Task, declaration) }

    context 'with scope declaration' do
      let(:declaration) { Filterameter::FilterDeclaration.new(:incomplete, {}) }

      it('returns true') { expect(inspector).to be_a_scope }
    end

    context 'with an attribute declaration' do
      let(:declaration) { Filterameter::FilterDeclaration.new(:description, {}) }

      it('returns false') { expect(inspector).not_to be_a_scope }
    end

    context 'with a nested scope' do
      let(:declaration) { Filterameter::FilterDeclaration.new(:in_progress, { association: %i[activity project] }) }

      it('returns true') { expect(inspector).to be_a_scope }
    end

    context 'with a nested attribute' do
      let(:declaration) { Filterameter::FilterDeclaration.new(:name, { association: %i[activity project] }) }

      it('returns true') { expect(inspector).not_to be_a_scope }
    end
  end

  context 'with direct collection association' do
    let(:inspector) do
      described_class.new(Project, Filterameter::FilterDeclaration.new(:name, { association: :activities }))
    end

    it('#any_collections?') { expect(inspector.any_collections?).to be true }
    it('#model_from_association') { expect(inspector.model_from_association).to eq Activity }
  end

  context 'with direct singular association' do
    let(:inspector) do
      described_class.new(Activity, Filterameter::FilterDeclaration.new(:name, { association: :project }))
    end

    it('#any_collections?') { expect(inspector.any_collections?).to be false }
    it('#model_from_association') { expect(inspector.model_from_association).to eq Project }
  end

  context 'with nested collection association' do
    let(:inspector) do
      described_class.new(Task,
                          Filterameter::FilterDeclaration.new(:name, { association: %i[activity activity_members] }))
    end

    it('#any_collections?') { expect(inspector.any_collections?).to be true }
    it('#model_from_association') { expect(inspector.model_from_association).to eq ActivityMember }
  end

  context 'with nested singular associations' do
    let(:inspector) do
      described_class.new(Task, Filterameter::FilterDeclaration.new(:name, { association: %i[activity project] }))
    end

    it('#any_collections?') { expect(inspector.any_collections?).to be false }
    it('#model_from_association') { expect(inspector.model_from_association).to eq Project }
  end

  context 'with invalid association' do
    let(:inspector) do
      described_class.new(Task, Filterameter::FilterDeclaration.new(:name, { association: %i[invalid_association] }))
    end

    it('raises error') do
      expect do
        inspector.model_from_association
      end.to raise_exception(Filterameter::Exceptions::InvalidAssociationDeclarationError)
    end
  end
end
