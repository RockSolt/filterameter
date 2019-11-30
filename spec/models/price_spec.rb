# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Price, type: :model do
  fixtures :prices

  it '.on_sale' do
    expect(described_class.on_sale).to contain_exactly(*prices(:blue_small, :blue_medium, :blue_large))
  end
end
