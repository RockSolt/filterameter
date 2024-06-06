# frozen_string_literal: true

class LegacyProjectsController < ApplicationController
  filter_model Project
  filter :priority, validates: { inclusion: { in: Project.priorities.keys } }

  def index
    @projects = build_query_from_filters

    render json: @projects
  end

  private

  def filter_parameters
    params.to_unsafe_h.fetch(:criteria, {})
  end
end
