# frozen_string_literal: true

class ActivitiesController < ApplicationController
  before_action :build_filtered_query, only: :index

  filter :activity_manager_id
  filter :manager_id, name: :activity_manager_id
  filter :incomplete
  filter :in_progress, name: :incomplete
  filter :task_count, range: true
  filter :min_only_task_count, name: :task_count, range: :min_only
  filter :max_only_task_count, name: :task_count, range: :max_only
  filter :project_priority, name: :priority, association: :project
  filter :tasks_completed, name: :completed, association: :tasks
  filter :high_priority, association: :project
  filter :incomplete_tasks, name: :incomplete, association: :tasks

  def index
    render json: @activities
  end
end
