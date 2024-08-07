# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Multi-level nested attribute filters' do
  fixtures :projects, :activities, :tasks, :users, :activity_members

  context 'with singular-to-singular association' do
    before { get '/tasks', params: { filter: { project_priority: 'high' } } }

    it 'returns the correct number of rows' do
      count = Task.joins(activity: :project).merge(Project.where(priority: 'high')).count
      expect(response.parsed_body.size).to eq count
    end

    it 'tasks on high priority projects include Pour coffee' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:pour_coffee).description)
    end
  end

  context 'with singular-to-collection association' do
    before { get '/tasks', params: { filter: { by_activity_member: users(:egg_chef).id } } }

    it 'returns the correct number of rows' do
      count = Task.joins(activity: :activity_members)
                  .merge(ActivityMember.where(user_id: users(:egg_chef).id))
                  .distinct.count
      expect(response.parsed_body.size).to eq count
    end

    it 'tasks on activities with Scrambles McGee include Make toast' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:make_toast).description)
    end
  end

  context 'with collection-to-singular association' do
    before { get '/projects', params: { filter: { activity_manager_active: false } } }

    it 'returns the correct number of rows' do
      count = Project.joins(activities: :activity_manager).merge(User.where(active: false)).distinct.count
      expect(response.parsed_body.size).to eq count
    end

    it 'projects with an inactive activity manager include Get some exercise' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('name' => projects(:exercise).name)
    end
  end

  context 'with collection-to-collection association' do
    before { get '/projects', params: { filter: { tasks_completed: false } } }

    it 'returns the correct number of rows' do
      count = Project.joins(activities: :tasks).merge(Task.where(completed: false)).distinct.count
      expect(response.parsed_body.size).to eq count
    end

    it 'projects with incomplete tasks do not include Read a book' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).not_to include_a_record_with('name' => projects(:read_a_book).name)
    end
  end

  context 'with singular-to-collection-to-singular' do
    before { get '/tasks', params: { filter: { activity_member_active: false } } }

    it 'returns the correct number of rows' do
      count = Task.joins(activity: { activity_members: :user }).merge(User.where(active: false)).distinct.count
      expect(response.parsed_body.size).to eq count
    end

    it 'tasks with inactive activity members include Make toast' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:make_toast).description)
    end
  end
end
