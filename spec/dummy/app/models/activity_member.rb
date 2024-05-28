# frozen_string_literal: true

class ActivityMember < ApplicationRecord
  belongs_to :activity
  belongs_to :user
end
