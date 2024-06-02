# frozen_string_literal: true

class ActivityMember < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  scope :inactive, -> { joins(:user).merge(User.inactive) }
end
