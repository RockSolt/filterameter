# frozen_string_literal: true

class ActivitiesController < ApplicationController
  filter :activity_manager_id
  filter :manager_id, name: :activity_manager_id

  def index
    activities = build_query

    render json: activities
  end
end
