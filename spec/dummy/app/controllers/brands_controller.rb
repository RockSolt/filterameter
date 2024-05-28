# frozen_string_literal: true

class BrandsController < ApplicationController
  filter :color, association: :shirts
  filter :size, association: :shirts

  def index
    brands = self.class.filter_coordinator.build_query(params.to_unsafe_h.fetch(:filter, {}))
    render json: brands
  end
end
