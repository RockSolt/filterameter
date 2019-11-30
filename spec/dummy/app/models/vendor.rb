# frozen_string_literal: true

class Vendor < ApplicationRecord
  has_many :brands

  def self.ships_by(date)
    days_away = (date.to_date - Date.tomorrow).to_i
    where(arel_table[:ship_time_in_days].lt(days_away))
  end
end
