# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::DeclarationsValidator do
  specify '#inspect' do
    validator = described_class.new('activities', Activity, nil)
    expect(validator.inspect).to eq 'filter declarations on ActivitiesController'
  end

  describe '#valid?' do
    let(:validator) { described_class.new('activities', Activity, registry) }

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

    let(:not_an_attribute_error) do
      <<~ERROR.chomp

        Invalid filter for 'not_an_attribute':
          Attribute 'not_an_attribute' does not exist on Activity
      ERROR
    end

    let(:updated_at_typo_error) do
      <<~ERROR.chomp

        Invalid sort for 'updated_at_typo':
          Attribute 'updated_at_typo' does not exist on Activity
      ERROR
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
        expect(validator.errors).to contain_exactly not_an_attribute_error
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
        expect(validator.errors).to contain_exactly updated_at_typo_error
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
        expect(validator.errors).to contain_exactly(not_an_attribute_error, updated_at_typo_error)
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
        expect(validator.errors).to contain_exactly <<~ERROR.chomp

          Invalid filter for 'inline_with_arg':
            Activity scope 'inline_with_arg' needs to be written as a class method, not as an inline scope
        ERROR
      end
    end
  end
end
