# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsController do
  it 'has valid declarations' do
    declarations = described_class.declarations_validator
    expect(declarations).to be_valid
  end
end
