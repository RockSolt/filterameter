# frozen_string_literal: true

class ProjectsController < ApplicationController
  filter :priority, validates: { inclusion: { in: Project.priorities.keys } }
  filter :activity_manager_active, name: :active, association: %i[activities activity_manager]
  filter :tasks_completed, name: :completed, association: %i[activities tasks]
  filter :with_inactive_activity_manager, name: :inactive, association: %i[activities activity_manager]
  filter :with_incomplete_tasks, name: :incomplete, association: %i[activities tasks]
  filter :in_progress
  filter :in_progress_as_of_days_ago, name: :in_progress do |value|
    Date.current - value.to_i.days
  end

  sort :by_created_at
  sort :by_project_id

  def index
    @projects = build_query_from_filters

    render json: @projects
  end
end
