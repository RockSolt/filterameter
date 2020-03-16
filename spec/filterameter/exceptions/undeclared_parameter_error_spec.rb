# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Exceptions::UndeclaredParameterError do
  let(:keys) { %w[collar size_with_typo] }
  let(:instance) { described_class.new(keys) }

  it '#message' do
    expect(instance.message).to eq "The following filter parameter(s) have not been declared: #{keys}"
  end

  it '#keys' do
    expect(instance.keys).to eq keys
  end
end
