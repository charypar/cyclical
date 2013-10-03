require 'cyclical/filters/months_filter'
require 'cyclical/filters/weekdays_filter'
require 'cyclical/filters/monthdays_filter'
require 'cyclical/filters/yeardays_filter'

module Cyclical

  # Rules describe the basic recurrence patterns (frequency and interval) and hold the set of rules (called filters)
  # that a candidate date must match to be included into the recurrence set.
  # Rules can align a date to a closest date (in the past or in the future) matching all the filters with respect to
  # selected start date of the recurrence.
  class Rule

    attr_reader :interval

    def initialize(interval = 1)
      @interval = interval
      @filters = []
      @filter_map = {}
    end

    # rule specification DSL

    def count(n = nil)
      return @count unless n

      @count = n
      self
    end

    def stop(t = nil)
      return @stop unless t

      @stop = t
      self
    end

    def months(*months)
      raise RuntimeError, "Months filter already set" if @filter_map[:month]

      f = MonthsFilter.new(*months)
      @filters << f
      @filter_map[:months] = f

      self
    end
    alias :month :months

    def weekdays(*weekdays)
      raise RuntimeError, "weekdays filter already set" if @filter_map[:weekdays]
      weekdays = [self] + weekdays

      f = WeekdaysFilter.new(*weekdays)
      @filters << f
      @filter_map[:weekdays] = f

      self
    end
    alias :weekday :weekdays

    def monthdays(*monthdays)
      raise RuntimeError, "monthdays filter already set" if @filter_map[:monthdays]

      f = MonthdaysFilter.new(*monthdays)
      @filters << f
      @filter_map[:monthdays] = f

      self
    end
    alias :monthday :monthdays

    def yeardays(*yeardays)
      raise RuntimeError, "yeardays filter already set" if @filter_map[:yeardays]

      f = YeardaysFilter.new(*yeardays)
      @filters << f
      @filter_map[:yeardays] = f

      self
    end
    alias :yearday :yeardays


    def filters(kind = nil)
      return @filters if kind.nil?

      @filter_map[kind.to_sym]
    end

    # rule API

    def finite?
      !infinite?
    end

    def infinite?
      @count.nil? && @stop.nil?
    end

    # returns true if time is aligned to the recurrence pattern and matches all the filters
    def match?(time, base)
      aligned?(time, base) && @filters.all? { |f| f.match?(time) }
    end

    # get next date matching the rule (not checking limits). Returns next occurrence even if +time+ matches the rule.
    def next(time, base)
      current = time
      until match?(current, base) && current > time
        pot_next = align(potential_next(current, base), base)
        pot_next += min_step if pot_next == current

        current = pot_next
      end

      current
    end

    # get previous date matching the rule (not checking limits). Returns next occurrence even if +time+ matches the rule.
    def previous(time, base)
      current = time
      until match?(current, base) && current < time
        pot_prev = align(potential_previous(current, base), base)
        pot_prev -= min_step if pot_prev == current

        current = pot_prev
      end

      current
    end

    # basic building blocks of the computations

    def aligned?(time, base)
      # for subclass to override
    end

    def step
      # for subclass to override
    end

    def to_hash
      hash = { :freq => self.class.to_s.underscore.split('/').last.split('_').first, :interval => @interval }

      hash[:count] = @count if @count
      hash[:stop] = @stop if @stop

      hash[:weekdays] = (filters(:weekdays).weekdays + [filters(:weekdays).ordered_weekdays]) if filters(:weekdays)
      hash[:monthdays] = filters(:monthdays).monthdays if filters(:monthdays)
      hash[:yeardays] = filters(:yeardays).yeardays if filters(:yeardays)
      hash[:months] = filters(:months).months if filters(:months)

      hash
    end

    def to_json
      to_hash.to_json
    end

    # factory methods

    class << self
      def daily(interval = 1)
        DailyRule.new(interval)
      end

      def yearly(interval = 1)
        YearlyRule.new(interval)
      end

      def weekly(interval = 1)
        WeeklyRule.new(interval)
      end

      def monthly(interval = 1)
        MonthlyRule.new(interval)
      end

      def from_hash(hash)
        raise "Bad Hash format: '#{hash.inspect}'" unless hash[:freq] && hash[:interval]

        rule = self.send(hash[:freq].to_sym, hash[:interval].to_i)

        rule.count(hash[:count]) if hash.has_key?(:count)
        rule.stop(hash[:stop]) if hash.has_key?(:stop)

        rule.weekdays(*hash[:weekdays]) if hash.has_key?(:weekdays)
        rule.monthdays(*hash[:monthdays]) if hash.has_key?(:monthdays)
        rule.yeardays(*hash[:yeardays]) if hash.has_key?(:yeardays)
        rule.months(*hash[:months]) if hash.has_key?(:months)

        rule
      end

      def from_json(json)
        h = JSON.parse(json)
        h['stop'] = Time.parse(h['stop']) if h['stop']

        from_hash(h.symbolize_keys)
      end
    end

    protected

    # Next comes the heart of all the calculations

    # Find a potential next date matching the rule as a maximum of next
    # valid dates from all the filters. Subclasses should add a check of
    # recurrence pattern match
    def potential_next(current, base)
      @filters.map { |f| f.next(current) }.max || current
    end

    # Find a potential previous date matching the rule as a minimum of previous
    # valid dates from all the filters. Subclasses should add a check of
    # recurrence pattern match
    def potential_previous(current, base)
      @filters.map { |f| f.previous(current) }.min || current
    end

    # Should return a time aligned to the base in the rule interval resolution, e.g.:
    # - in a daily rule a time on the same day with a correct hour, minute and second
    # - in a weekly rule a time in the same week with a correct weekday, hour, minute and second
    def align(time, base)
      raise NotImplementedError, "#{self.class}.align should be overriden and return a time in the period of time parameter, aligned to base"
    end

    # Minimal step of all the filters and the recurrence rule. This allows the
    # next/previous calculation to move a sane amount of time forward when all
    # the filters and the rule match but the candidate is before/after the
    # requested time (which is caused by date alignment)
    def min_step
      @min_step ||= ([step] + @filters.map { |f| f.step }).min
    end
  end
end
