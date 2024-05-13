# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Filterameter::DeclarativeFilters
end
