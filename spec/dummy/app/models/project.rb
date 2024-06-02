# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :activities

  # enum signature changed in Rails 7
  if method(:enum).arity == 1
    enum priority: %i[low medium high], _suffix: true
  else
    enum :priority, %i[low medium high], suffix: true
  end

  def self.in_progress(as_of)
    where(start_date: ..as_of)
      .where(end_date: as_of..)
  end
end
