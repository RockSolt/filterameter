# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Helpers::RequestedSort do
  context 'with no sign' do
    let(:result) { described_class.parse('created_at') }

    it('#name') { expect(result.name).to eq 'created_at' }
    it('#direction') { expect(result.direction).to eq :asc }
  end

  context 'with plus sign' do
    let(:result) { described_class.parse('+created_at') }

    it('#name') { expect(result.name).to eq 'created_at' }
    it('#direction') { expect(result.direction).to eq :asc }
  end

  context 'with minus sign' do
    let(:result) { described_class.parse('-created_at') }

    it('#name') { expect(result.name).to eq 'created_at' }
    it('#direction') { expect(result.direction).to eq :desc }
  end
end
