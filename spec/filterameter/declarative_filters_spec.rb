# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::DeclarativeFilters do
  describe '.filter_model' do
    let(:model_class) { controller.filter_coordinator.instance_variable_get('@model_class') }

    context 'with model as string' do
      let(:controller) do
        Class.new(ApplicationController) do
          @controller_name = 'bars'
          @controller_path = 'foo/bars'
          include Filterameter::DeclarativeFilters

          filter_model 'Project'
        end
      end

      it 'assigns model class' do
        expect(model_class).to be Project
      end
    end

    context 'with model as class' do
      let(:controller) do
        Class.new(ApplicationController) do
          @controller_name = 'bars'
          @controller_path = 'foo/bars'
          include Filterameter::DeclarativeFilters

          filter_model Project
        end
      end

      it 'assigns model class' do
        expect(model_class).to be Project
      end
    end
  end

  describe '.filter_query_var_name' do
    let(:controller) do
      Class.new(ApplicationController) do
        @controller_name = 'bars'
        @controller_path = 'foo/bars'
        include Filterameter::DeclarativeFilters

        filter_query_var_name :price_data
      end
    end

    it 'assigns model class' do
      expect(controller.filter_coordinator.query_variable_name).to be :price_data
    end
  end
end
