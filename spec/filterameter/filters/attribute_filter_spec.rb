# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Filters::AttributeFilter do
  it 'applies filter to query' do
    filter = described_class.new(:color)
    query = class_spy('ActiveRecord::Base')

    filter.apply(query, 'blue')
    expect(query).to have_received(:where).with(color: 'blue')
  end

  it 'is valid with valid attribute' do
    filter = described_class.new(:name)
    expect(filter.valid?(Activity)).to be true
  end

  context 'with invalid attribute' do
    let(:filter) { described_class.new(:not_a_thing) }

    it 'is not valid' do
      expect(filter.valid?(Activity)).to be false
    end

    it 'reports errors' do
      filter.valid?(Activity)
      expect(filter.errors)
        .to contain_exactly Filterameter::DeclarationErrors::NoSuchAttributeError.new('Activity', :not_a_thing)
    end
  end
end
