# frozen_string_literal: true

class ActiveActivitiesController < ApplicationController
  filter_model 'Activity'
  filter :project_id

  def index
    render json: build_query_from_filters(Activity.incomplete)
  end
end
