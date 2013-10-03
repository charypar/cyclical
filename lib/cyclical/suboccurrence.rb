module Cyclical
  # Holds suboccurrence of a schedule, i.e. time interval which is a subinterval of a single occurrence.
  # This is used to find actual time spans to display in a given time interval (for example in a calendar)
  class Suboccurrence
    attr_reader :start, :end, :occurrence_start, :occurrence_end

    alias :occurrence_start? :occurrence_start
    alias :occurrence_end? :occurrence_end

    # factory method for finding suboccurrence of a single occurrence with an interval, with the ability to return nil
    # This might be a totally bad idea, I'm not sure right now really...
    def self.find(attrs)
      raise ArgumentError, "Missing occurrence" unless (occurrence = attrs[:occurrence]).is_a?(Range)
      raise ArgumentError, "Missing interval" unless (interval = attrs[:interval]).is_a?(Range)

      return nil if occurrence.last <= interval.first || occurrence.first >= interval.last

      suboccurrence = {}

      if occurrence.first < interval.first
        suboccurrence[:start] = interval.first
        suboccurrence[:occurrence_start] = false
      else
        suboccurrence[:start] = occurrence.first
        suboccurrence[:occurrence_start] = true
      end

      if occurrence.last > interval.last
        suboccurrence[:end] = interval.last
        suboccurrence[:occurrence_end] = false
      else
        suboccurrence[:end] = occurrence.last
        suboccurrence[:occurrence_end] = true
      end

      return new(suboccurrence)
    end

    private

    def initialize(attrs)
      @start = attrs[:start]
      @end = attrs[:end]
      @occurrence_start = attrs[:occurrence_start]
      @occurrence_end = attrs[:occurrence_end]
    end
  end
end
