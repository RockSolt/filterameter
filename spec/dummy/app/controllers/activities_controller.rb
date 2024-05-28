# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def index
    @activities = Activity.all

    render json: @activities
  end
end
