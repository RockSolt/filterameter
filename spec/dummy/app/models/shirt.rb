# frozen_string_literal: true

class Shirt < ApplicationRecord
  belongs_to :brand
  has_one :price

  scope :blue, -> { where(color: 'blue') }
end
