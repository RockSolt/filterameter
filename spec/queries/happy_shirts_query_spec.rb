# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HappyShirtsQuery do
  fixtures :shirts
  fixtures :brands

  let(:filter) { {} }
  let(:query) { described_class.build_query(filter, nil) }

  shared_examples 'count is correct' do |count|
    it { expect(query.count).to eq count }
  end

  describe 'default plus additional criteria' do
    let(:filter) { { size: 'Medium' } }

    it_behaves_like 'count is correct', 1
  end

  context 'when default overridden' do
    let(:query) { described_class.build_query(filter, Shirt.all) }
    let(:filter) { { size: 'Medium' } }

    it_behaves_like 'count is correct', 2
  end
end
