# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Attribute sorts', type: :request do
  fixtures :projects, :activities, :users, :tasks

  context 'with filter declaration' do
    before { get '/activities', params: { filter: { sort: :activity_manager_id } } }

    it 'sorts' do
      expect(response).to have_http_status(:success)
      ordered = response.parsed_body.pluck('activity_manager_id')
      expect(ordered).to eq Activity.order(activity_manager_id: :asc).pluck(:activity_manager_id)
    end
  end

  context 'when plus sign specified' do
    before { get '/activities', params: { filter: { sort: '+activity_manager_id' } } }

    it 'sorts ascending' do
      expect(response).to have_http_status(:success)
      ordered = response.parsed_body.pluck('activity_manager_id')
      expect(ordered).to eq Activity.order(activity_manager_id: :asc).pluck(:activity_manager_id)
    end
  end

  context 'when minus sign specified' do
    before { get '/activities', params: { filter: { sort: '-activity_manager_id' } } }

    it 'sorts descending' do
      expect(response).to have_http_status(:success)
      ordered = response.parsed_body.pluck('activity_manager_id')
      expect(ordered).to eq Activity.order(activity_manager_id: :desc).pluck(:activity_manager_id)
    end
  end

  context 'with name specified' do
    before { get '/activities', params: { filter: { sort: :manager_id } } }

    it 'sorts correctly' do
      expect(response).to have_http_status(:success)
      ordered = response.parsed_body.pluck('activity_manager_id')
      expect(ordered).to eq Activity.order(activity_manager_id: :asc).pluck(:activity_manager_id)
    end
  end

  context 'when declared with `sort`' do
    before { get '/activities', params: { filter: { sort: :completed } } }

    it 'sorts' do
      expect(response).to have_http_status(:success)
      ordered = response.parsed_body.pluck('completed')
      expect(ordered).to eq Activity.order(completed: :asc).pluck(:completed)
    end
  end

  context 'when declared with `sorts`' do
    before { get '/tasks', params: { filter: { sort: :activity_id } } }

    it 'sorts' do
      expect(response).to have_http_status(:success)
      ordered = response.parsed_body.pluck('activity_id')
      expect(ordered).to eq Task.order(activity_id: :asc).pluck(:activity_id)
    end
  end

  context 'with an array of sorts' do
    before { get '/activities', params: { filter: { sort: %i[completed -project_id] } } }

    it 'sorts' do
      expect(response).to have_http_status(:success)
      ordered = response.parsed_body.pluck('id')
      expect(ordered).to eq Activity.order(completed: :asc, project_id: :desc).pluck(:id)
    end
  end

  context 'with singular association' do
    before { get '/activities', params: { filter: { sort: :project_priority } } }

    it 'sorts' do
      expect(response).to have_http_status(:success)
      ordered = response.parsed_body.pluck('id')
      expect(ordered).to eq Activity.joins(:project).merge(Project.order(priority: :asc)).pluck(:id)
    end
  end
end
