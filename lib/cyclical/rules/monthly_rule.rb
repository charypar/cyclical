require 'cyclical/rule'

module Cyclical
  # holds weekly rule configuration
  class MonthlyRule < Rule

    # check if time is aligned to a base time, including interval check
    def aligned?(time, base)
      return false unless ((12 * base.year + base.mon) - (12 * time.year + time.mon)) % @interval == 0
      return false unless [time.hour, time.min, time.sec] == [base.hour, base.min, base.sec] # the shortest filter we support is for days
      return false unless base.day == time.day || monthday_filters

      true
    end

    # default step of the rule
    def step
      @interval.months
    end

    protected

    def potential_next(current, base)
      candidate = super(current, base)

      rem = ((12 * base.year + base.mon) - (12 * candidate.year + candidate.mon)) % @interval
      return candidate if rem == 0

      (candidate + rem.months).beginning_of_month
    end

    def potential_previous(current, base)
      candidate = super(current, base)

      rem = ((12 * base.year + base.mon) - (12 * candidate.year + candidate.mon)) % @interval
      return candidate if rem == 0

      (candidate + rem.months - step).end_of_month
    end

    def align(time, base)
      time = time.beginning_of_month + (base.day - 1).days unless time.day == base.day || monthday_filters

      # compensate crossing DST barrier (oh my...)
      offset = time.beginning_of_day.utc_offset
      time = time.beginning_of_day + base.hour.hours + base.min.minutes + base.sec.seconds
      time += (offset - time.utc_offset)

      time
    end

    def monthday_filters
      filters(:weekdays) || filters(:monthdays) || filters(:yeardays) || filters(:weeks) || filters(:months)
    end
  end
end
