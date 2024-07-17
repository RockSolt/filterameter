# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Filterameter::Errors do
  context 'without a validate implementation' do
    let(:filter) do
      Class.new do
        include Filterameter::Errors
      end.new
    end

    it 'is valid' do
      expect(filter).to be_valid
    end
  end

  context 'with a validate implementation' do
    let(:filter) do
      Class.new do
        include Filterameter::Errors

        private

        def validate(dummy_error)
          return if dummy_error.nil?

          @errors << dummy_error
        end
      end.new
    end

    it 'is valid with no error' do
      expect(filter).to be_valid
    end

    context 'with an error' do
      it 'is not valid' do
        expect(filter.valid?('error message')).to be false
      end

      it 'includes error message' do
        filter.valid?('error message')
        expect(filter.errors).to contain_exactly 'error message'
      end
    end
  end
end
