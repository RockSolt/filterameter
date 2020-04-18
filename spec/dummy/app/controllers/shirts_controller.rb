# frozen_string_literal: true

class ShirtsController < ApplicationController
  before_action :start_query
  before_action :build_filtered_query, only: :index

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

  private

  # provides test case for existing query when params include flag
  def start_query
    return unless params.key?(:with_existing_query)

    @shirts = Shirt.where(color: 'Blue')
  end
end
