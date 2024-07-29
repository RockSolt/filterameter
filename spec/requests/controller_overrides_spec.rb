# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Controller overrides' do
  fixtures :projects, :activities

  context 'with nested key overridden' do
    before { get '/legacy_projects', params: { criteria: { priority: 'high' } } }

    it 'returns the correct number of rows' do
      count = Project.high_priority.count
      expect(response.parsed_body.size).to eq count
    end

    it 'high priority projects include Start day on the right foot' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('name' => projects(:start_day).name)
    end
  end

  context 'with starting query' do
    before { get '/active_activities', params: { filter: { project_id: projects(:start_day).id } } }

    it 'returns the correct number of rows' do
      count = Activity.where(completed: false, project_id: projects(:start_day).id).count
      expect(response.parsed_body.size).to eq count
    end

    it 'active activities on Start Day project include Good Breakfast' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('name' => activities(:good_breakfast).name)
    end
  end

  context 'with filter_parameters overridden' do
    fixtures :tasks

    before { get '/active_tasks', params: { filter: { activity_id: activities(:good_breakfast).id } } }

    it 'returns the correct number of rows' do
      count = Task.where(completed: false, activity_id: activities(:good_breakfast).id).count
      expect(response.parsed_body.size).to eq count
    end

    it 'active tasks on Good Breakfast include Make Toast' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:make_toast).description)
    end
  end
end
