# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Helpers::JoinsValuesBuilder do
  it 'returns association name with single entry' do
    expect(described_class.build(%i[the_name])).to eq :the_name
  end

  it 'returns nested hash with two entries' do
    expect(described_class.build(%i[a b])).to eq({ a: { b: {} } })
  end
end
