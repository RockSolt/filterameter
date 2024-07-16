# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Configuration do
  let(:config) { described_class.new }

  describe 'getters and setters' do
    %w[action_on_undeclared_parameters action_on_validation_failure].each do |attribute|
      it("##{attribute}=") { expect(config).to respond_to("#{attribute}=") }
      it("##{attribute}") { expect(config).to respond_to(attribute) }
    end
  end

  context 'development environment' do
    before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development')) }

    it '#action_on_undeclared_parameters' do
      expect(config.action_on_undeclared_parameters).to eq :log
    end

    it '#action_on_validation_failure' do
      expect(config.action_on_validation_failure).to eq :log
    end
  end

  context 'test environment' do
    it '#action_on_undeclared_parameters' do
      expect(config.action_on_undeclared_parameters).to eq :raise
    end

    it '#action_on_validation_failure' do
      expect(config.action_on_validation_failure).to eq :raise
    end
  end

  context 'production environment' do
    before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production')) }

    it '#action_on_undeclared_parameters' do
      expect(config.action_on_undeclared_parameters).to be false
    end

    it '#action_on_validation_failure' do
      expect(config.action_on_validation_failure).to be false
    end
  end

  describe '#filter_key' do
    it('defaults to :filter') { expect(config.filter_key).to eq :filter }

    it 'can be overrriden' do
      config.filter_key = :criteria
      expect(config.filter_key).to eq :criteria
    end

    it 'can be set to false' do
      config.filter_key = false
      expect(config.filter_key).to be false
    end
  end
end
