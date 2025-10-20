# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Validators::InclusionValidator do
  let(:record) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :size

      def self.name
        'InclusionValidatorTestModel'
      end
    end.new
  end

  shared_examples 'flags attribute as invalid' do
    specify(:aggregate_failures) do
      expect(record.errors).not_to be_empty
      expect(record.errors).to include(:size)
      expect(record.errors.full_messages).to contain_exactly('Size is not included in the list')
    end
  end

  context 'with single values' do
    let(:validator) { described_class.new(attributes: %i[size], in: %w[Small Medium Large]) }

    it 'valid with single value' do
      validator.validate_each(record, :size, 'Small')
      expect(record.errors).to be_empty
    end

    context 'with incorrect value' do
      before { validator.validate_each(record, :size, 'XL') }

      it_behaves_like 'flags attribute as invalid'
    end
  end

  context 'with multiple values allowed' do
    let(:validator) do
      described_class.new(attributes: %i[size], in: %w[Small Medium Large], allow_multiple_values: true)
    end

    it 'valid with single value' do
      validator.validate_each(record, :size, 'Small')
      expect(record.errors).to be_empty
    end

    context 'with incorrect value' do
      before { validator.validate_each(record, :size, 'XL') }

      it_behaves_like 'flags attribute as invalid'
    end

    it 'valid with two values' do
      validator.validate_each(record, :size, %w[Small Medium])
      expect(record.errors).to be_empty
    end

    context 'with two values when one is wrong' do
      before { validator.validate_each(record, :size, %w[Large XL]) }

      it_behaves_like 'flags attribute as invalid'
    end

    context 'with multiple incorrect values' do
      before { validator.validate_each(record, :size, %w[Large XL XXL XXXL]) }

      it_behaves_like 'flags attribute as invalid'
    end
  end
end
