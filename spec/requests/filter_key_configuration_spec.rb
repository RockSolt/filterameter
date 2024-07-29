# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filter Key configuration' do
  fixtures :activities

  before { allow(Filterameter).to receive(:configuration).and_return(custom_config) }

  context 'with key overriden to f' do
    let(:custom_config) { Filterameter::Configuration.new.tap { |c| c.filter_key = :f } }

    it 'applies filter' do
      get '/activities', params: { f: { incomplete: true } }
      count = Activity.incomplete.count
      expect(response.parsed_body.size).to eq count

      names = Activity.incomplete.pluck(:name)
      expect(response.parsed_body.pluck('name')).to match_array(names)
    end

    it 'applies sort' do
      get '/activities', params: { f: { sort: :project_id } }

      ordered = Activity.order(:project_id).pluck(:project_id)
      expect(response.parsed_body.pluck('project_id')).to eq ordered
    end

    it 'fails on undeclared params (default for test env)' do
      expect { get '/activities', params: { f: { not_a_filter: true } } }
        .to raise_error(Filterameter::Exceptions::UndeclaredParameterError)
    end
  end

  context 'without nesting' do
    let(:custom_config) { Filterameter::Configuration.new.tap { |c| c.filter_key = false } }

    it 'applies filter' do
      get '/activities', params: { incomplete: true }
      count = Activity.incomplete.count
      expect(response.parsed_body.size).to eq count

      names = Activity.incomplete.pluck(:name)
      expect(response.parsed_body.pluck('name')).to match_array(names)
    end

    it 'applies sort' do
      get '/activities', params: { sort: :project_id }

      ordered = Activity.order(:project_id).pluck(:project_id)
      expect(response.parsed_body.pluck('project_id')).to eq ordered
    end

    it 'ignores undeclared params' do
      get '/activities', params: { not_a_filter: true }
      expect(response).to be_successful
    end
  end
end
