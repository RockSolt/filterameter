# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::FilterCoordinator do
  describe 'constructor tries to populate model class from controller name and path' do
    let(:controller_name) { 'my_models' }
    let(:controller_path) { 'foo_bar/my_models' }
    let(:model) { instance_double(Class) }
    let(:result) { described_class.new(controller_name, controller_path).send(:model_class) }

    context 'with model MyModel' do
      before { stub_const('MyModel', model) }

      it { expect(result).to be model }
    end

    context 'with model FooBar::MyModel' do
      before { stub_const('FooBar::MyModel', model) }

      it { expect(result).to be model }
    end

    it 'raises error with no such model' do
      expect { result }.to raise_exception Filterameter::Exceptions::CannotDetermineModelError
    end
  end

  describe '#model_class=' do
    let(:instance) { described_class.new(nil, nil) }
    let(:result) { instance.send(:model_class) }

    it 'handles string' do
      instance.model_class = described_class.name
      expect(result).to eq described_class
    end

    it 'handles class' do
      instance.model_class = described_class
      expect(result).to eq described_class
    end
  end
end
