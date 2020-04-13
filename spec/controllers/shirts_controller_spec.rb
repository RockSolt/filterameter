# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShirtsController, type: :controller do
  fixtures :shirts
  let(:response_body) { JSON.parse(response.body) }

  shared_examples 'successful response' do
    it { expect(response).to be_successful }
  end

  shared_examples 'count is correct' do |count|
    it { expect(response_body.size).to eq count }
  end

  describe 'with no filters' do
    before { get :index }

    it_behaves_like 'successful response'
    it_behaves_like 'count is correct', 6
  end

  context 'with filter(s)' do
    before { get :index, params: { filter: filter } }

    describe 'attribute filter -> color: blue' do
      let(:filter) { { color: 'Blue' } }

      it_behaves_like 'successful response'
      it_behaves_like 'count is correct', 3
    end

    describe 'two filters' do
      let(:filter) { { color: 'Blue', size: 'Medium' } }

      it_behaves_like 'successful response'
      it_behaves_like 'count is correct', 1
    end

    describe 'attribute filter with array of values' do
      let(:filter) { { size: %w[Medium Large] } }

      it_behaves_like 'successful response'
      it_behaves_like 'count is correct', 4
    end

    describe 'nested filter with name option' do
      fixtures :brands
      let(:filter) { { brand_name: 'Happy Shirts' } }

      it_behaves_like 'successful response'
      it_behaves_like 'count is correct', 3
    end
  end

  context 'with instance variable already populated' do
    before { get :index, params: { with_existing_query: true, filter: { size: 'Medium' } } }

    it_behaves_like 'successful response'
    it_behaves_like 'count is correct', 1
  end

  context 'with invalid parameter value' do
    let(:filter) { { size: 'Extra Large' } }
    let(:request) { get :index, params: { filter: filter } }

    it 'raises ValidationError' do
      expect { request }
        .to raise_error(Filterameter::Exceptions::ValidationError,
                        'The following parameter(s) failed validation: ["Size is not included in the list"]')
    end
  end
end
