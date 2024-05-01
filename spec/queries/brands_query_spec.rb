# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrandsQuery do
  fixtures :brands

  context 'when looking for brands with blue shirts' do
    let(:query) { described_class.build_query({ color: 'Blue' }, nil) }

    it { expect(query.count).to eq 1 }
    it('finds Happy Shirts') { expect(query.first.name).to eq 'Happy Shirts' }
  end

  context 'when looking for brands with large shirts' do
    let(:query) { described_class.build_query({ size: 'Large' }, nil) }

    it { expect(query.count).to eq 2 }
  end
end
