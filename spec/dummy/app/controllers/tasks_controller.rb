# frozen_string_literal: true

class TasksController < ApplicationController
  filter :completed
  filter :description, partial: true
  filter :description_starts_with, name: :description, partial: :from_start
  filter :description_case_sensitive, name: :description, partial: { case_sensitive: true }
  filter :description_dynamic, name: :description, partial: { match: :dynamic }
  filter :project_priority, name: :priority, association: %i[activity project]
  filter :by_activity_member, name: :user_id, association: %i[activity activity_members]
  filter :activity_member_active, name: :active, association: %i[activity activity_members user]
  filter :low_priority_projects, name: :low_priority, association: %i[activity project]
  filter :with_inactive_activity_manager, name: :inactive, association: %i[activity activity_manager]
  filter :with_inactive_activity_member, name: :inactive, association: %i[activity activity_members]

  sorts :activity_id, :completed

  def index
    @tasks = build_query_from_filters

    render json: @tasks
  end
end
