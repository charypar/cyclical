require 'cyclical/rule'

require 'cyclical/rules/daily_rule'
require 'cyclical/rules/weekly_rule'
require 'cyclical/rules/monthly_rule'
require 'cyclical/rules/yearly_rule'

require 'cyclical/occurrence'

module Cyclical
  class Schedule

    attr_reader :start_time
    attr_accessor :end_time

    def initialize(start_time, rule = nil)
      @occurrence = Occurrence.new rule, start_time unless rule.nil?
      @start_time = @occurrence ? @occurrence.start_time : start_time
    end

    def rule=(rule)
      @occurrence = (rule.nil? ? nil : Occurrence.new(rule, start_time))
      @occurrence.duration = end_time ? (end_time - start_time) : 0
    end

    def rule
      @occurrence.nil? ? nil : @occurrence.rule
    end

    def end_time=(time)
      raise "End time is before start time" if time < @start_time
      @end_time = time
      @occurrence.duration = (time - start_time) unless @occurrence.nil?

      time
    end

    # query interface

    def first(n)
      return [start_time] if @occurrence.nil?

      @occurrence.next_occurrences(n, start_time)
    end

    # first occurrence in [time, infinity)
    def next_occurrence(time)
      return (start_time < time ? nil : start_time) if @occurrence.nil?

      @occurrence.next_occurrence(time)
    end

    # last occurrence in (-infinity, time)
    def previous_occurrence(time)
      return (start_time >= time ? nil : start_time) if @occurrence.nil?

      @occurrence.previous_occurrence(time)
    end

    def occurrences(end_time = nil)
      raise ArgumentError, "You have to specify end time for an infinite schedule occurrence listing" if end_time.nil? && @occurrence && @occurrence.rule.infinite?

      if end_time
        occurrences_between(start_time, end_time)
      else
        return [start_time] if @occurrence.nil?

        @occurrence.all
      end
    end

    # occurrences in [t1, t2)
    def occurrences_between(t1, t2)
      return ((start_time < t1 || @start_time >= t2) ? [] : [start_time]) if @occurrence.nil?

      @occurrence.occurrences_between(t1, t2)
    end

    def suboccurrences_between(t1, t2)
      raise RuntimeError, "Schedule must have an end time to compute suboccurrences" unless end_time

      return [Suboccurrence.find(:occurrence => start_time..end_time, :interval => t1..t2)] if @occurrence.nil?

      @occurrence.suboccurrences_between(t1, t2)
    end

    def to_hash
      hash = @occurrence.nil? ? {} : @occurrence.to_hash.clone

      hash[:start] = start_time
      hash[:end] = end_time if end_time

      hash
    end

    def to_json
      to_hash.to_json
    end

    def self.from_hash(hash)
      rule = hash.clone
      start_time = hash.delete(:start)
      end_time = hash.delete(:end)

      rule = hash[:freq] && hash[:interval] ? Rule.from_hash(hash) : nil

      s = Schedule.new start_time, rule
      s.end_time = end_time

      s
    end

    def self.from_json(json)
      h = JSON.parse(json)

      h['start'] = Time.parse(h['start']) if h['start']
      h['end'] = Time.parse(h['end']) if h['end']
      h['stop'] = Time.parse(h['stop']) if h['stop']

      from_hash(h.symbolize_keys)
    end
  end
end
