# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :project
  belongs_to :activity_manager, class_name: 'User'
  has_many :activity_members
  has_many :tasks

  scope :incomplete, -> { where(completed: false) }

  # this could be handled by attribute sort, added here for testing purposes only
  def self.by_task_count(dir)
    order(task_count: dir)
  end

  # no visibility to the arg when inline, so filterameter assumes it is a conditional scope
  scope :inline_with_arg, ->(arg) { where(completed: arg) }

  # a class method that would get flagged as a scope by the factory, but does not return an arel
  def self.not_a_scope(arg)
    arg
  end

  # a class method that would get flagged as a conditional scope by the factory, but does not return an arel
  def self.not_a_conditional_scope
    42
  end

  # filters only support single argument scopes
  def self.scope_with_multiple_args(completed, name)
    where(completed:, name:)
  end

  # sort scopes must have exactly one argement
  scope :inline_sort_scope_with_no_args, -> { Activity.order(:created_at) }

  def self.sort_scope_with_no_args
    Activity.order(:created_at)
  end

  def self.sort_scope_with_two_args(one, two)
    Activity.order(one, two)
  end
end
