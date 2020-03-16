# frozen_string_literal: true

require 'rails_helper'

require 'filterameter/parameters_base'

RSpec.describe Filterameter::ParametersBase do
  let(:parameters) do
    Class.new(described_class).tap do |pc|
      pc.add_validation(:size, [inclusion: { in: %w[Small Medium Large] }])
      pc.add_validation(:percent_reduced, [{ numericality: { greater_than: 0 } },
                                           { numericality: { less_than: 100 } }])
    end.new({})
  end

  %i[size percent_reduced].each do |attribute|
    it "has getter for #{attribute}" do
      expect(parameters).to respond_to(attribute)
    end

    it "has setter for #{attribute}" do
      expect(parameters).to respond_to("#{attribute}=")
    end
  end

  context 'with valid size' do
    before { parameters.size = 'Small' }

    it { expect(parameters).to be_valid }
  end

  context 'with valid percent_reduced' do
    before { parameters.percent_reduced = 20 }

    it { expect(parameters).to be_valid }
  end

  context 'with invalid size' do
    before { parameters.size = 'Extra Small' }

    it { expect(parameters).not_to be_valid }

    it 'contains error' do
      parameters.valid?
      expect(parameters.errors.full_messages).to include('Size is not included in the list')
    end
  end
end
