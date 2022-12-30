# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples_for_shirts'

RSpec.describe StringKeyQuery do
  fixtures :shirts

  let(:filter) { {} }
  let(:starting_query) { nil }
  let(:query) { described_class.build_query(filter, starting_query) }

  shared_examples 'count is correct' do |count|
    it { expect(query.count).to eq count }
  end

  shared_examples 'raises ValidationError' do |message|
    it do
      expect { query.take }
        .to raise_error(Filterameter::Exceptions::ValidationError,
                        "The following parameter(s) failed validation: #{message}")
    end
  end

  it_behaves_like 'applies filter parameters'
end
