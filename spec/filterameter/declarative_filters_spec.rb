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

  describe '.sorts' do
    let(:coordinator) { controller.filter_coordinator }
    let(:controller) do
      Class.new(ApplicationController) do
        @controller_name = 'projects'
        @controller_path = 'projects'
        include Filterameter::DeclarativeFilters

        sorts :name, :priority
      end
    end

    it 'registers name and priority as sorts' do
      expect(coordinator.instance_variable_get('@registry').sort_parameter_names).to include('name', 'priority')
    end

    it 'does not register name and priority as filters' do
      expect(coordinator.filter_parameter_names).not_to include('name', 'priority')
    end
  end

  describe '#query_parameters' do
    let(:controller_class) do
      Class.new(ApplicationController) do
        @controller_name = 'projects'
        @controller_path = 'projects'
        include Filterameter::DeclarativeFilters

        default_sort created_at: :desc
      end
    end
    let(:controller) { controller_class.new }

    it 'uses the controller default sort when the request has no explicit sort' do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(filter: { status: 'active' }))

      expect(controller.query_parameters.sort).to eq('-created_at')
    end

    it 'uses the requested sort instead of the controller default' do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(filter: { sort: 'name' }))

      expect(controller.query_parameters.sort).to eq('name')
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
