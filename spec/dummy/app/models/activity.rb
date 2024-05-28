# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :project
  belongs_to :activity_manager, class_name: 'User'
end
