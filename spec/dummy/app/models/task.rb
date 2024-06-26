# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :activity

  scope :incomplete, -> { where(completed: false) }
end
