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

  let(:registry) { described_class.new(echo_factory) }

  it 'adds and fetches sort' do
    registry.add(:foo, {})
    result = registry.fetch(:foo)
    expect(result).to be_a Filterameter::SortDeclaration
    expect(result.name).to eq 'foo'
  end
end
