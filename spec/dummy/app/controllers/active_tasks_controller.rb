# frozen_string_literal: true

class ActiveTasksController < ApplicationController
  filter_model Task
  filters :activity_id, :completed

  def index
    @tasks = build_query_from_filters

    render json: @tasks
  end

  private

  def filter_parameters
    super.merge(completed: false)
  end
end
