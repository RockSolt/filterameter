# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrandsController, type: :controller do
  fixtures :brands, :shirts

  let(:brand_with_blue_shirts) { brands(:happy_shirts) }
  let(:response_body) { response.parsed_body }

  context 'when looking for brands with blue shirts' do
    let(:response) { get :index, params: { filter: { color: 'Blue' } } }

    it { expect(response).to be_successful }
    it { expect(response_body.size).to eq 1 }
    it('finds Happy Shirts') { expect(response_body.first).to include('name' => brand_with_blue_shirts.name) }
  end

  context 'when looking for brands with large shirts' do
    let(:response) { get :index, params: { filter: { size: 'Large' } } }

    it { expect(response).to be_successful }
    it { expect(response_body.size).to eq 2 }
  end
end
