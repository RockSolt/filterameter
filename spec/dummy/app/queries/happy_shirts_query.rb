# frozen_string_literal: true

# = Happy Shirts Query
#
# Class HappyShirtsQuery builds queries for the Happy Shirts brand.
class HappyShirtsQuery
  include Filterameter::DeclarativeFilters

  model 'Shirt'
  default_query Shirt.joins(:brand).merge(Brand.where(name: 'Happy Shirts'))

  filter :color
  filter :size, validates: { inclusion: { in: %w[Small Medium Large], allow_multiple_values: true } }
end
