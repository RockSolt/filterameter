# frozen_string_literal: true

RSpec.shared_examples 'applies filter parameters' do
  describe 'with no filters' do
    let(:filter) { {} }

    it_behaves_like 'count is correct', 6
  end

  context 'with filter(s)' do
    describe 'attribute filter -> color: blue' do
      let(:filter) { { color: 'Blue' } }

      it_behaves_like 'count is correct', 3
    end

    describe 'two filters' do
      let(:filter) { { color: 'Blue', size: 'Medium' } }

      it_behaves_like 'count is correct', 1
    end

    describe 'attribute filter with array of values' do
      let(:filter) { { size: %w[Medium Large] } }

      it_behaves_like 'count is correct', 4
    end

    describe 'nested filter with name option' do
      fixtures :brands
      let(:filter) { { brand_name: 'Happy Shirts' } }

      it_behaves_like 'count is correct', 3
    end

    describe 'partial match from start' do
      let(:filter) { { color_type_ahead: 'Bl' } }

      it_behaves_like 'count is correct', 3
    end

    describe 'partial match anywhere' do
      let(:filter) { { fuzzy_color: 'lu' } }

      it_behaves_like 'count is correct', 3
    end

    describe 'partial match dynamically' do
      let(:filter) { { color_client_search: 'B__e' } }

      it_behaves_like 'count is correct', 3
    end

    describe 'case sensitive partial' do
      fixtures :brands

      context 'when case sensitive' do
        let(:filter) do
          Shirt.create!(color: 'blue', brand: brands('happy_shirts'))
          { case_sensitive_color: 'bl' }
        end

        it_behaves_like 'count is correct', 1
      end

      context 'when not case sensitive' do
        let(:filter) do
          Shirt.create!(color: 'blue', brand: brands('happy_shirts'))
          { fuzzy_color: 'bl' }
        end

        it_behaves_like 'count is correct', 4
      end
    end

    describe 'price range' do
      fixtures :prices

      context 'from 11.99 - 21.99' do
        let(:filter) { { price_min: 11.99, price_max: 21.99 } }

        it_behaves_like 'count is correct', 3
      end

      context 'from 11.99' do
        let(:filter) { { price_min: 11.99 } }

        it_behaves_like 'count is correct', 6
      end

      context 'up to 19.99' do
        let(:filter) { { price_max: 19.99 } }

        it_behaves_like 'count is correct', 3
      end

      context 'attribute filter still works' do
        let(:filter) { { price: 19.99 } }

        it_behaves_like 'count is correct', 3
      end
    end
  end

  context 'with invalid parameter value' do
    let(:filter) { { size: 'Extra Large' } }

    it_behaves_like 'raises ValidationError', '["Size is not included in the list"]'
  end

  context 'with array of values that has an invalid value' do
    let(:filter) { { size: %w[Medium Large Big] } }

    it_behaves_like 'raises ValidationError', '["Size is not included in the list"]'
  end
end
