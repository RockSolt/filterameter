# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Partial filters' do
  fixtures :tasks

  context 'with defaults' do
    before { get '/tasks', params: { filter: { description: 'beans' } } }

    it 'returns the correct number of rows' do
      count = Task.where("description like '%beans%'").count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Grind coffee beans' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:grind_coffee_beans).description)
    end
  end

  context 'with from start option' do
    before { get '/tasks', params: { filter: { description_starts_with: 'Add beans' } } }

    it 'returns the correct number of rows' do
      count = Task.where("description like 'Add beans%'").count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Add beans and water to french press' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:french_press).description)
    end
  end

  context 'with case sensitive option' do
    before { get '/tasks', params: { filter: { description_case_sensitive: 'Add beans' } } }

    it 'returns the correct number of rows' do
      count = Task.where("description ilike 'Add beans%'").count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Add beans and water to french press' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:french_press).description)
    end
  end

  context 'with case sensitive option and no match' do
    before { get '/tasks', params: { filter: { description_case_sensitive: 'add beans' } } }

    it 'returns the no rows' do
      expect(response.parsed_body.size).to be_zero
    end
  end

  context 'with dynamic option' do
    before { get '/tasks', params: { filter: { description_dynamic: '%beans%' } } }

    it 'returns the correct number of rows' do
      count = Task.where("description like '%beans%'").count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Grind coffee beans' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include_a_record_with('description' => tasks(:grind_coffee_beans).description)
    end
  end
end
