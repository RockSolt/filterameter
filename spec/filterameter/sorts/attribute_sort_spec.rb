# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Sorts::AttributeSort do
  let(:sort) { described_class.new(:color) }
  let(:query) { class_spy('ActiveRecord::Base') }

  it 'applies sort to query' do
    sort.apply(query, :asc)
    expect(query).to have_received(:order).with(color: :asc)
  end

  it 'is valid with valid attribute' do
    sort = described_class.new(:name)
    expect(sort.valid?(Activity)).to be true
  end

  context 'with invalid attribute' do
    let(:sort) { described_class.new(:not_a_thing) }

    it 'is not valid' do
      expect(sort.valid?(Activity)).to be false
    end

    it 'reports errors' do
      sort.valid?(Activity)
      expect(sort.errors)
        .to contain_exactly Filterameter::DeclarationErrors::NoSuchAttributeError.new(Activity, :not_a_thing)
    end
  end
end
