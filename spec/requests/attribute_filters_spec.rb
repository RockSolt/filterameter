# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Attribute filters' do
  fixtures :activities, :users, :tasks

  context 'with no options' do
    before { get '/activities', params: { filter: { activity_manager_id: users(:joe_jackson).id } } }

    it 'returns the correct number of rows' do
      count = Activity.where(activity_manager_id: users(:joe_jackson).id).count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Get dressed' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('name' => activities(:look_sharp).name)
    end
  end

  context 'with name specified' do
    before { get '/activities', params: { filter: { manager_id: users(:joe_jackson).id } } }

    it 'returns the correct number of rows' do
      count = Activity.where(activity_manager_id: users(:joe_jackson).id).count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Get dressed' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('name' => activities(:look_sharp).name)
    end

    it 'does not return Make coffee' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).not_to include_a_record_with('name' => activities(:make_coffee).name)
    end
  end

  context 'with validations' do
    fixtures :projects
    before { get '/projects', params: { filter: { priority: 'high' } } }

    it 'returns the correct number of rows' do
      count = Project.high_priority.count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Start day on the right foot' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('name' => projects(:start_day).name)
    end
  end

  context 'with validations and invalid value' do
    fixtures :projects

    it 'raises validation error' do
      expect { get '/projects', params: { filter: { priority: 'top' } } }
        .to raise_exception(Filterameter::Exceptions::ValidationError)
    end
  end

  context 'with empty filters' do
    before { get '/activities', params: { filter: { manager_id: users(:joe_jackson).id, activity_manager_id: '' } } }

    it 'returns the correct number of rows' do
      count = Activity.where(activity_manager_id: users(:joe_jackson).id).count
      expect(response.parsed_body.size).to eq count
    end
  end

  context 'with boolean filter set to true' do
    before { get '/tasks', params: { filter: { completed: true } } }

    it 'returns the correct number of rows' do
      count = Task.where(completed: true).count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Grind coffee beans' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:grind_coffee_beans).description)
    end

    it 'does not return Make toast' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).not_to include_a_record_with('description' => tasks(:make_toast).description)
    end
  end

  context 'with boolean filter set to false' do
    before { get '/tasks', params: { filter: { completed: false } } }

    it 'returns the correct number of rows' do
      count = Task.where(completed: false).count
      expect(response.parsed_body.size).to eq count
    end

    it 'does not return Grind coffee beans' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).not_to include_a_record_with('description' => tasks(:grind_coffee_beans).description)
    end

    it 'returns Make toast' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:make_toast).description)
    end
  end
end
