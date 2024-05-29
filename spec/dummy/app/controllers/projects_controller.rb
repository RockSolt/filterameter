# frozen_string_literal: true

class ProjectsController < ApplicationController
  filter :priority, validates: { inclusion: { in: Project.priorities.keys } }

  def index
    @projects = build_query

    render json: @projects
  end
end
