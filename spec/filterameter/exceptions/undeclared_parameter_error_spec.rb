# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Exceptions::UndeclaredParameterError do
  let(:instance) { described_class.new(:foo) }

  it '#message' do
    expect(instance.message).to eq 'The following filter parameter has not been declared: foo'
  end

  it '#key' do
    expect(instance.key).to eq :foo
  end
end
