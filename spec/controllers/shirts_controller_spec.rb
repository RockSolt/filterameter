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

  shared_examples 'raises ValidationError' do |message|
    it do
      expect { request }
        .to raise_error(Filterameter::Exceptions::ValidationError,
                        "The following parameter(s) failed validation: #{message}")
    end
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

    describe 'partial match from start' do
      let(:filter) { { color_type_ahead: 'Bl' } }

      it_behaves_like 'successful response'
      it_behaves_like 'count is correct', 3
    end

    describe 'partial match anywhere' do
      let(:filter) { { fuzzy_color: 'lu' } }

      it_behaves_like 'successful response'
      it_behaves_like 'count is correct', 3
    end

    describe 'partial match dynamically' do
      let(:filter) { { color_client_search: 'B__e' } }

      it_behaves_like 'successful response'
      it_behaves_like 'count is correct', 3
    end

    describe 'case sensitive partial' do
      fixtures :brands

      context 'when case sensitive' do
        let(:filter) do
          Shirt.create!(color: 'blue', brand: brands('happy_shirts'))
          { case_sensitive_color: 'bl' }
        end

        # it_behaves_like 'successful response'
        it_behaves_like 'count is correct', 1
      end

      context 'when not case sensitive' do
        let(:filter) do
          Shirt.create!(color: 'blue', brand: brands('happy_shirts'))
          { fuzzy_color: 'bl' }
        end

        it_behaves_like 'successful response'
        it_behaves_like 'count is correct', 4
      end
    end

    describe 'price range' do
      fixtures :prices

      context 'from 11.99 - 21.99' do
        let(:filter) { { price_min: 11.99, price_max: 21.99 } }

        it_behaves_like 'successful response'
        it_behaves_like 'count is correct', 3
      end

      context 'from 11.99' do
        let(:filter) { { price_min: 11.99 } }

        it_behaves_like 'successful response'
        it_behaves_like 'count is correct', 6
      end

      context 'up to 19.99' do
        let(:filter) { { price_max: 19.99 } }

        it_behaves_like 'successful response'
        it_behaves_like 'count is correct', 3
      end

      context 'attribute filter still works' do
        let(:filter) { { price: 19.99 } }

        it_behaves_like 'successful response'
        it_behaves_like 'count is correct', 3
      end
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

    it_behaves_like 'raises ValidationError', '["Size is not included in the list"]'
  end

  context 'with array of values that has an invalid value' do
    let(:filter) { { size: %w[Medium Large Big] } }
    let(:request) { get :index, params: { filter: filter } }

    it_behaves_like 'raises ValidationError', '["Size is not included in the list"]'
  end
end
