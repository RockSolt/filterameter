# frozen_string_literal: true

# = Shirts Query
#
# Class ShirtsQuery builds a query based on the declared the filter parameters.
class ShirtsQuery
  include Filterameter::DeclarativeFilters

  model 'Shirt'

  filter :color
  filter :size, validates: { inclusion: { in: %w[Small Medium Large], allow_multiple_values: true } }
  filter :brand_name, association: :brand, name: :name
  filter :on_sale, association: :price, validates: [{ numericality: { greater_than: 0 } },
                                                    { numericality: { less_than: 100 } }]
  filter :color_type_ahead, name: :color, partial: { match: :from_start }
  filter :fuzzy_color, name: :color, partial: true
  filter :color_client_search, name: :color, partial: { match: :dynamic }
  filter :case_sensitive_color, name: :color, partial: { case_sensitive: true }
  filter :price, name: :current, association: :price, range: true
end
