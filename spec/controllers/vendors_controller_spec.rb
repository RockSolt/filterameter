# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VendorsController, type: :controller do
  fixtures :vendors, :brands, :shirts

  let(:brand_with_blue_shirts) { brands(:happy_shirts) }
  let(:response_body) { response.parsed_body }

  context 'with brand name query' do
    let(:response) { get :index, params: { filter: { brand_name: brand_with_blue_shirts.name } } }

    it { expect(response).to be_successful }
    it { expect(response_body.size).to eq 1 }
    it { expect(response_body.first).to include('name' => brand_with_blue_shirts.vendor.name) }
  end

  context 'when filter has multi-level association' do
    let(:response) { get :index, params: { filter: { shirt_color: 'Blue' } } }

    it { expect(response).to be_successful }
    it { expect(response_body.size).to eq 1 }
    it { expect(response_body.first).to include('name' => brand_with_blue_shirts.vendor.name) }
  end
end
