# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vendor, type: :model do
  fixtures :vendors

  describe '.ships_by' do
    it 'nothing by tomorrow' do
      expect(described_class.ships_by(Date.tomorrow)).to be_empty
    end

    it 'Happy House in five days' do
      expect(described_class.ships_by(5.days.from_now)).to contain_exactly(vendors(:happy_house))
    end

    it 'all ships by next week' do
      expect(described_class.ships_by(10.days.from_now).size).to eq 2
    end
  end
end
