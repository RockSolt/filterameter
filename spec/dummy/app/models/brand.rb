# frozen_string_literal: true

class Brand < ApplicationRecord
  belongs_to :vendor
  has_many :shirts
end
