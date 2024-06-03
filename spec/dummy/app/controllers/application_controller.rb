# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Filterameter::DeclarativeFilters

  private

  def build_query
    self.class.filter_coordinator.build_query(params.to_unsafe_h.fetch(:filter, {}))
  end
end
