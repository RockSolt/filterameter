# frozen_string_literal: true

# = Brands Query
#
# Class BrandsQuery builds a query based on the declared the filter parameters.
class BrandsQuery
  include Filterameter::DeclarativeFilters

  model 'Brand'

  filter :color, association: :shirts
  filter :size, association: :shirts
end
