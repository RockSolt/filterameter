# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Query parameters path helpers' do
  let(:params) do
    ActionController::Parameters.new(
      filter: { sort: 'completed' },
      page: { number: '2', size: '10' }
    )
  end
  let(:request_parameters) { Filterameter::RequestParameters.new(params) }
  let(:query_params) { Filterameter::QueryParameters.new(request_parameters) }

  describe '#for_sort' do
    it 'generates a URL with the new sort and no page number' do
      get activities_path(query_params.for_sort(:project_id))

      expect(response).to have_http_status(:success)
      expect(response.parsed_body.pluck('project_id')).to eq Activity.order(project_id: :asc).pluck(:project_id)
    end

    it 'toggles direction when the field is already sorted in the initial direction' do
      get activities_path(query_params.for_sort(:completed, initial_direction: :asc))

      expect(response).to have_http_status(:success)
      expect(response.parsed_body.pluck('completed')).to eq Activity.order(completed: :desc).pluck(:completed)
    end

    it 'removes the sort when the field is sorted opposite to the initial direction' do
      get activities_path(query_params.for_sort(:completed, initial_direction: :desc))

      expect(response).to have_http_status(:success)
      expect(response.parsed_body.pluck('project_id')).to eq Activity.order(project_id: :desc).pluck(:project_id)
    end
  end

  describe 'default sort interactions' do
    let(:params) do
      ActionController::Parameters.new(page: { number: '2', size: '10' })
    end
    let(:query_params) do
      Filterameter::QueryParameters.new(request_parameters, default_sort: { project_id: :desc })
    end

    it 'changes the effective order when toggling a descending default with ascending initial direction' do
      generated_params = query_params.for_sort(:project_id, initial_direction: :asc)

      get activities_path(generated_params)

      expect(response).to have_http_status(:success)
      expect(response.parsed_body.pluck('project_id')).to eq Activity.order(project_id: :asc).pluck(:project_id)
    end
  end

  describe '#for_page' do
    it 'generates a URL with the updated page number and preserves the sort' do
      get activities_path(query_params.for_page(3))

      expect(response).to have_http_status(:success)
      expect(response.parsed_body.pluck('completed')).to eq Activity.order(completed: :asc).pluck(:completed)
    end

    context 'with multiple sorts' do
      let(:params) do
        ActionController::Parameters.new(
          filter: { sort: %w[-project_id completed] },
          page: { number: '1', size: '10' }
        )
      end

      it 'preserves the multi-field sort' do
        get activities_path(query_params.for_page(2))

        expect(response).to have_http_status(:success)
        expect(response.parsed_body.pluck('id')).to eq Activity.order(project_id: :desc, completed: :asc).pluck(:id)
      end
    end
  end

  describe '#for_size' do
    it 'generates a URL with the updated page size, no page number, and preserves the sort' do
      get activities_path(query_params.for_size(20))

      expect(response).to have_http_status(:success)
      expect(response.parsed_body.pluck('completed')).to eq Activity.order(completed: :asc).pluck(:completed)
    end
  end
end
