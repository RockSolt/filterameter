# frozen_string_literal: true

class ShirtsController < ApplicationController
  include Filterameter::DeclarativeFilters

  filter :color
  filter :size, validates: { inclusion: { in: %w[Small Medium Large] }, unless: -> { size.is_a? Array } }
  filter :brand_name, association: :brand, name: :name
  filter :on_sale, association: :price, validates: [{ numericality: { greater_than: 0 } },
                                                    { numericality: { less_than: 100 } }]

  # GET /shirts
  def index
    params.permit(:color)
    render json: @shirts
  end
end
