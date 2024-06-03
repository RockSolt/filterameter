# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Conditional scope filters', type: :request do
  fixtures :activities, :users

  context 'when true' do
    before { get '/activities', params: { filter: { incomplete: true } } }

    it 'returns the correct number of rows' do
      count = Activity.where(completed: false).count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Have a good breakfast' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body.first).to include('name' => activities(:good_breakfast).name)
    end
  end

  context 'when false' do
    before { get '/activities', params: { filter: { incomplete: false } } }

    it 'does not apply the scope' do
      count = Activity.count
      expect(response.parsed_body.size).to eq count
    end
  end

  context 'with name specified' do
    before { get '/activities', params: { filter: { in_progress: true } } }

    it 'returns the correct number of rows' do
      count = Activity.where(completed: false).count
      expect(response.parsed_body.size).to eq count
    end

    it 'returns Have a good breakfast' do
      expect(response).to have_http_status(:success)
      expect(response.parsed_body.first).to include('name' => activities(:good_breakfast).name)
    end
  end

  context 'with name specified and false' do
    before { get '/activities', params: { filter: { in_progress: false } } }

    it 'does not apply the scope' do
      count = Activity.count
      expect(response.parsed_body.size).to eq count
    end
  end
end

RSpec.describe 'Scopes with argument filters', type: :request do
  fixtures :projects

  before { get '/projects', params: { filter: { in_progress: 1.day.from_now } } }

  it 'returns the correct number of rows' do
    count = Project.in_progress(1.day.from_now).count
    expect(response.parsed_body.size).to eq count
  end

  it 'returns Start day on the right foot' do
    expect(response).to have_http_status(:success)
    expect(response.parsed_body).to include_a_record_with('name' => projects(:start_day).name)
  end
end
