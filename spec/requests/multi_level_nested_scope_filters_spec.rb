# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nested scope filters' do
  fixtures :projects, :activities, :tasks, :users, :activity_members

  context 'with singular-to-singular association' do
    before { get '/tasks', params: { filter: { low_priority_projects: 'low' } } }

    it 'returns the correct number of rows' do
      count = Task.joins(activity: :project).merge(Project.where(priority: 'low')).count
      expect(response.parsed_body.size).to eq count
    end

    it 'tasks on low priority projects include Apply sunscreen' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:wear_sunscreen).description)
    end
  end

  context 'with singular-to-collection association' do
    before { get '/tasks', params: { filter: { with_inactive_activity_member: true } } }

    it 'returns the correct number of rows' do
      count = Task.joins(activity: :activity_members)
                  .merge(ActivityMember.inactive)
                  .distinct.count
      expect(response.parsed_body.size).to eq count
    end

    it 'tasks on activities with an inactive member include Make toast' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:make_toast).description)
    end
  end

  context 'with collection-to-singular association' do
    before { get '/projects', params: { filter: { with_inactive_activity_manager: true } } }

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
    before { get '/projects', params: { filter: { with_incomplete_tasks: true } } }

    it 'returns the correct number of rows' do
      count = Project.joins(activities: :tasks).merge(Task.where(completed: false)).distinct.count
      expect(response.parsed_body.size).to eq count
    end

    it 'projects with incomplete tasks do not include Read a book' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).not_to include_a_record_with('name' => projects(:read_a_book).name)
    end
  end
end
