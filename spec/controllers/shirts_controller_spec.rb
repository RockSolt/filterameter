# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples_for_shirts'

RSpec.describe ShirtsController, type: :controller do
  let(:response_body) { JSON.parse(response.body) }

  shared_examples 'count is correct' do |count|
    let(:response) { get :index, params: { filter: filter } }

    it { expect(response).to be_successful }
    it { expect(response_body.size).to eq count }
  end

  shared_examples 'raises ValidationError' do |message|
    it do
      expect { get :index, params: { filter: filter } }
        .to raise_error(Filterameter::Exceptions::ValidationError,
                        "The following parameter(s) failed validation: #{message}")
    end
  end

  it_behaves_like 'applies filter parameters'

  context 'with instance variable already populated' do
    let(:response) { get :index, params: { with_existing_query: true, filter: { size: 'Medium' } } }

    it { expect(response).to be_successful }
    it { expect(response_body.size).to eq 1 }
  end
end
