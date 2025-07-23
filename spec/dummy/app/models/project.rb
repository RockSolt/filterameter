# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :activities, dependent: :destroy

  # enum signature changed in Rails 7
  if method(:enum).arity == 1
    enum priority: { low: 0, medium: 1, high: 2 }, _suffix: true # rubocop:disable Rails/EnumSyntax
  else
    enum :priority, { low: 0, medium: 1, high: 2 }, suffix: true
  end

  def self.in_progress(as_of)
    where(start_date: ..as_of)
      .where(end_date: as_of..)
  end

  def self.by_created_at(dir)
    order(created_at: dir)
  end

  # could be handled by an attribute sort, added for testing purposes only
  scope :by_project_id, ->(dir) { order(id: dir) }

  # multi-argument scope, not valid for filter
  def self.multi_arg_scope(active, priority)
    where(active:, priority:)
  end
end
