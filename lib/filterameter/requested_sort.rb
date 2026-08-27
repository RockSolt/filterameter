# frozen_string_literal: true

module Filterameter
  # A parsed sort request containing a field name and direction.
  class RequestedSort
    attr_reader :name, :direction

    def self.parse(sort)
      result = Helpers::SortSerializer.deserialize(sort)
      new(result[:name], result[:direction])
    end

    def initialize(name, direction)
      @name = name
      @direction = direction
      freeze
    end
  end
end
