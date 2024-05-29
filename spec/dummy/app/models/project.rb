# frozen_string_literal: true

class Project < ApplicationRecord
  enum :priority, %i[low medium high], suffix: true

  def self.in_progress(as_of)
    where(start_date: ..as_of)
      .where(end_date: as_of..)
  end
end
