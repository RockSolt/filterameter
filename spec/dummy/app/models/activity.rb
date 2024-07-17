# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :project
  belongs_to :activity_manager, class_name: 'User'
  has_many :activity_members
  has_many :tasks

  scope :incomplete, -> { where(completed: false) }

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
end
