# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Scope sorts', type: :request do
  fixtures :projects

  context 'with class method scope' do
    before { get '/projects', params: { filter: { sort: :by_created_at } } }

    it 'returns successfully' do
      expect(response).to have_http_status(:success)
    end
  end

  context 'with inline scope' do
    before { get '/projects', params: { filter: { sort: 'by_project_id' } } }

    it 'sorts projects by id asc' do
      ordered = response.parsed_body.pluck('id')
      expect(ordered).to eq Project.order(id: :asc).pluck(:id)
    end
  end
end
