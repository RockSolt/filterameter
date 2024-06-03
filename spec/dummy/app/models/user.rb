# frozen_string_literal: true

class User < ApplicationRecord
  scope :inactive, -> { where(active: false) }
end
