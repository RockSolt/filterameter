# frozen_string_literal: true

class VendorsController < ApplicationController
  filter :shirt_color, association: %i[brands shirts], name: :color
  filter :brand_name, association: :brands, name: :name
  filter :ships_by

  def index
    vendors = self.class.filter_coordinator.build_query(params.to_unsafe_h.fetch(:filter, {}))
    render json: vendors
  end
end
