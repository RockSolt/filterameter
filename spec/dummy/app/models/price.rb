# frozen_string_literal: true

class Price < ApplicationRecord
  belongs_to :shirt

  # example of TrueOnlyScope; it should only be applied when on_sale is true
  scope :on_sale, -> { where(arel_table[:current].lt(arel_table[:original])) }

  # original - current / original = percent reduced
  def self.percent_reduced(percentage)
    where(arel_table[:current] / arel_table[:original].lteq(1 - percentage.to_f / 100))
  end
end
