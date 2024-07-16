# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Default sorts', type: :request do
  fixtures :projects, :activities

  context 'with no default specified' do
    before { get '/projects' }

    it 'sorts by primary key desc' do
      ordered = response.parsed_body.pluck('id')
      expect(ordered).to eq Project.order(id: :desc).pluck(:id)
    end
  end

  context 'with default specified' do
    before { get '/activities' }

    it 'sorts by default' do
      ordered = response.parsed_body.pluck('project_id')
      expect(ordered).to eq Activity.order(project_id: :desc).pluck(:project_id)
    end
  end
end
