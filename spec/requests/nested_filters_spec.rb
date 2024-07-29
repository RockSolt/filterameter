# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nested filters' do
  describe 'attribute filters' do
    fixtures :projects, :activities, :tasks

    context 'with singular association' do
      before { get '/activities', params: { filter: { project_priority: 'high' } } }

      it 'returns the correct number of rows' do
        count = Activity.joins(:project).merge(Project.where(priority: 'high')).count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Make coffee' do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include_a_record_with('name' => activities(:make_coffee).name)
      end
    end

    context 'with collection association' do
      before { get '/activities', params: { filter: { tasks_completed: true } } }

      it 'returns the correct number of rows' do
        count = Activity.joins(:tasks).merge(Task.where(completed: true)).distinct.count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Make coffee' do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include_a_record_with('name' => activities(:make_coffee).name)
      end
    end
  end

  describe 'scope filters' do
    fixtures :projects, :activities, :tasks

    context 'with singular association' do
      before { get '/activities', params: { filter: { high_priority: 'true' } } }

      it 'returns the correct number of rows' do
        count = Activity.joins(:project).merge(Project.where(priority: 'high')).count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Make coffee' do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include_a_record_with('name' => activities(:make_coffee).name)
      end
    end

    context 'with conditional scope that is false' do
      before { get '/activities', params: { filter: { high_priority: 'false' } } }

      it 'does not apply the scope' do
        count = Activity.count
        expect(response.parsed_body.size).to eq count
      end
    end

    context 'with collection association' do
      before { get '/activities', params: { filter: { incomplete_tasks: true } } }

      it 'returns the correct number of rows' do
        count = Activity.joins(:tasks).merge(Task.where(completed: false)).distinct.count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Have a good breakfast' do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include_a_record_with('name' => activities(:good_breakfast).name)
      end
    end
  end
end
