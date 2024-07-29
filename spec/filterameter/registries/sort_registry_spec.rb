# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Registries::SortRegistry do
  let(:echo_factory) do
    Class.new do
      def build(name)
        name
      end
    end.new
  end

  let(:declaration) do
    registry = described_class.new(echo_factory)
    registry.add(:foo, {})
    registry.fetch(:foo)
  end

  it('is a sort declaration') { expect(declaration).to be_a Filterameter::SortDeclaration }
  it('has name') { expect(declaration.name).to eq 'foo' }
end
