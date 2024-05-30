# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Range filters', type: :request do
  fixtures :activities

  context 'when range: true' do
    context 'with exact value' do
      before { get '/activities', params: { filter: { task_count: 3 } } }

      it 'returns the correct number of rows' do
        count = Activity.where(task_count: 3).count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Have a good breakfast' do
        expect(response.parsed_body).to include_a_record_with('name' => activities(:good_breakfast).name)
      end
    end

    context 'with minimum value' do
      before { get '/activities', params: { filter: { task_count_min: 3 } } }

      it 'returns the correct number of rows' do
        count = Activity.where('task_count >= 3').count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Have a good breakfast' do
        expect(response.parsed_body).to include_a_record_with('name' => activities(:good_breakfast).name)
      end
    end

    context 'with maximum value' do
      before { get '/activities', params: { filter: { task_count_max: 3 } } }

      it 'returns the correct number of rows' do
        count = Activity.where('task_count <= 3').count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Get dressed' do
        expect(response.parsed_body).to include_a_record_with('name' => activities(:look_sharp).name)
      end
    end
  end

  context 'when range: :min_only' do
    context 'with exact value', skip: 're-evaluating min_only feature' do
      before { get '/activities', params: { filter: { min_only_task_count: 3 } } }

      it 'returns the correct number of rows' do
        count = Activity.where(task_count: 3).count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Have a good breakfast' do
        expect(response.parsed_body).to include_a_record_with('name' => activities(:good_breakfast).name)
      end
    end

    context 'with minimum value' do
      before { get '/activities', params: { filter: { min_only_task_count_min: 3 } } }

      it 'returns the correct number of rows' do
        count = Activity.where('task_count >= 3').count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Have a good breakfast' do
        expect(response.parsed_body).to include_a_record_with('name' => activities(:good_breakfast).name)
      end
    end
  end

  context 'when range: :max_only' do
    context 'with exact value', skip: 're-evaluating max_only feature' do
      before { get '/activities', params: { filter: { max_only_task_count: 3 } } }

      it 'returns the correct number of rows' do
        count = Activity.where(task_count: 3).count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Have a good breakfast' do
        expect(response.parsed_body).to include_a_record_with('name' => activities(:good_breakfast).name)
      end
    end

    context 'with maximum value' do
      before { get '/activities', params: { filter: { max_only_task_count_max: 3 } } }

      it 'returns the correct number of rows' do
        count = Activity.where('task_count <= 3').count
        expect(response.parsed_body.size).to eq count
      end

      it 'returns Get dressed' do
        expect(response.parsed_body).to include_a_record_with('name' => activities(:look_sharp).name)
      end
    end
  end
end
