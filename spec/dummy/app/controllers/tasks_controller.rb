# frozen_string_literal: true

class TasksController < ApplicationController
  def index
    @tasks = Task.all

    render json: @tasks
  end
end
