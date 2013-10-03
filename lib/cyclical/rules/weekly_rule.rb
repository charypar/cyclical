require 'cyclical/rule'

module Cyclical
  # holds daily rule configuration
  class WeeklyRule < Rule

    # check if time is aligned to a base time, including interval check
    def aligned?(time, base)
      return false unless ((base.beginning_of_week - time.beginning_of_week) / 604800).to_i % @interval == 0 # 604800 = 7.days
      return false unless [time.hour, time.min, time.sec] == [base.hour, base.min, base.sec] # the shortest filter we support is for days

      return false unless base.wday == time.wday || weekday_filters

      # wow, passed every test
      true
    end

    # default step of the rule
    def step
      @interval.weeks
    end

    protected

    def potential_next(current, base)
      candidate = super(current, base)

      rem = ((base.beginning_of_week - candidate.beginning_of_week) / 604800).to_i % @interval
      return candidate if rem == 0

      (candidate + rem.weeks).beginning_of_week
    end

    def potential_previous(current, base)
      candidate = super(current, base)

      rem = ((base.beginning_of_week - candidate.beginning_of_week) / 604800).to_i % @interval
      return candidate if rem == 0

      (candidate + rem.weeks - step).end_of_week
    end

    def align(time, base)
      time = time.beginning_of_week + base.wday.days unless time.wday == base.wday || weekday_filters

      # compensate crossing DST barrier (oh my...)
      offset = time.beginning_of_day.utc_offset
      time = time.beginning_of_day + base.hour.hours + base.min.minutes + base.sec.seconds
      time += (offset - time.utc_offset)

      time
    end

    def weekday_filters
      filters(:weekdays) || filters(:monthdays) || filters(:yeardays) || filters(:yeardays) || filters(:weeks) || filters(:months)
    end
  end
end
