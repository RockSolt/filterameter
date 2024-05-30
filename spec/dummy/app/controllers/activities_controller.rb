# frozen_string_literal: true

class ActivitiesController < ApplicationController
  filter :activity_manager_id
  filter :manager_id, name: :activity_manager_id
  filter :incomplete
  filter :in_progress, name: :incomplete
  filter :task_count, range: true
  filter :min_only_task_count, name: :task_count, range: :min_only
  filter :max_only_task_count, name: :task_count, range: :max_only

  def index
    activities = build_query

    render json: activities
  end
end
