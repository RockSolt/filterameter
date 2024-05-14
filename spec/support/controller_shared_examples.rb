# frozen_string_literal: true

RSpec.shared_examples 'count is correct' do |count|
  let(:response) { get :index, params: { filter: filter } }

  it { expect(response).to be_successful }
  it { expect(response_body.size).to eq count }
end

RSpec.shared_examples 'raises ValidationError' do |message|
  it do
    expect { get :index, params: { filter: filter } }
      .to raise_error(Filterameter::Exceptions::ValidationError,
                      "The following parameter(s) failed validation: #{message}")
  end
end
