# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::DeclarationsValidator do
  let(:not_an_attribute_error) do
    <<~ERROR.chomp

      Invalid filter for 'not_an_attribute':
        #{Filterameter::DeclarationErrors::NoSuchAttributeError.new('Activity', :not_an_attribute)}
    ERROR
  end
  let(:updated_at_typo_error) do
    <<~ERROR.chomp

      Invalid sort for 'updated_at_typo':
        Attribute 'updated_at_typo' does not exist on Activity
    ERROR
  end
  let(:validator) { described_class.new('activities', Activity, registry) }

  specify '#inspect' do
    activity_validator = described_class.new('activities', Activity, nil)
    expect(activity_validator.inspect).to eq 'filter declarations on ActivitiesController'
  end

  context 'with valid filters and sorts' do
    let(:registry) do
      Filterameter::Registries::Registry.new(Activity).tap do |r|
        r.add_filter(:name, {})
        r.add_filter(:task_count, {})
        r.add_sort(:created_at, {})
        r.add_sort(:updated_at, {})
      end
    end

    it 'is valid' do
      validator = described_class.new('activities', Activity, registry)
      expect(validator).to be_valid
    end
  end

  context 'with invalid filter' do
    let(:registry) do
      Filterameter::Registries::Registry.new(Activity).tap do |r|
        r.add_filter(:name, {})
        r.add_filter(:not_an_attribute, {})
        r.add_sort(:created_at, {})
        r.add_sort(:updated_at, {})
      end
    end

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'reports error' do
      validator.valid?
      expect(validator.errors).to eq not_an_attribute_error
    end
  end

  context 'with invalid sort' do
    let(:registry) do
      Filterameter::Registries::Registry.new(Activity).tap do |r|
        r.add_filter(:name, {})
        r.add_sort(:created_at, {})
        r.add_sort(:updated_at_typo, {})
      end
    end

    let(:validator) { described_class.new('activities', Activity, registry) }

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'reports error' do
      validator.valid?
      expect(validator.errors).to eq updated_at_typo_error
    end
  end

  context 'with invalid filter and invalid sort' do
    let(:registry) do
      Filterameter::Registries::Registry.new(Activity).tap do |r|
        r.add_filter(:name, {})
        r.add_filter(:not_an_attribute, {})
        r.add_sort(:created_at, {})
        r.add_sort(:updated_at_typo, {})
      end
    end

    let(:validator) { described_class.new('activities', Activity, registry) }

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'reports error' do
      validator.valid?
      expect(validator.errors).to eq [not_an_attribute_error, updated_at_typo_error].join("\n")
    end
  end

  context 'with inline scope that should be class method' do
    let(:registry) do
      Filterameter::Registries::Registry.new(Activity).tap do |r|
        r.add_filter(:inline_with_arg, {})
      end
    end

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'reports error' do
      validator.valid?
      expect(validator.errors).to eq <<~ERROR.chomp

        Invalid filter for 'inline_with_arg':
          #{Filterameter::DeclarationErrors::CannotBeInlineScopeError.new('Activity', :inline_with_arg)}
      ERROR
    end
  end

  describe 'filter factory error handling' do
    let(:registry) do
      Filterameter::Registries::Registry.new(Activity).tap do |r|
        r.add_filter(:name, {})
      end
    end

    before { allow(registry).to receive(:fetch_filter).and_raise(error) }

    context 'when error is expected' do
      let(:error) { Filterameter::DeclarationErrors::NoSuchAttributeError.new('Activity', :name) }

      it 'is not valid' do
        expect(validator).not_to be_valid
      end

      it 'reports error' do
        validator.valid?
        expect(validator.errors).to eq <<~ERROR.chomp

          Invalid filter for 'name':
            #{described_class::FactoryErrors.new(error)}
        ERROR
      end
    end

    context 'when error is unexpected' do
      let(:error) { StandardError.new('That was unexpected!') }

      it 'is not valid' do
        expect(validator).not_to be_valid
      end

      it 'reports error' do
        validator.valid?
        expect(validator.errors).to eq <<~ERROR.chomp

          Invalid filter for 'name':
            #{Filterameter::DeclarationErrors::UnexpectedError.new(error)}
        ERROR
      end
    end
  end
end
