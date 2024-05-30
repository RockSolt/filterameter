# frozen_string_literal: true

class TasksController < ApplicationController
  filter :description, partial: true
  filter :description_starts_with, name: :description, partial: :from_start
  filter :description_case_sensitive, name: :description, partial: { case_sensitive: true }
  filter :description_dynamic, name: :description, partial: { match: :dynamic }

  def index
    @tasks = build_query

    render json: @tasks
  end
end
