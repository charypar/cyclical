require 'cyclical/rule'

module Cyclical
  # holds daily rule configuration
  class YearlyRule < Rule

    # check if time is aligned to a base time, including interval check
    def aligned?(time, base)
      return false unless (base.year - time.year).to_i % @interval == 0
      return false unless [time.hour, time.min, time.sec] == [base.hour, base.min, base.sec] # the shortest filter we support is for days
      return false unless time.day == base.day || filters(:weekdays) || filters(:monthdays) || filters(:yeardays)
      return false unless time.month == base.month || filters(:yeardays) || filters(:weeks) || filters(:months)

      # wow, passed every test
      true
    end

    # default step of the rule
    def step
      @interval.years
    end

    private

    # closest valid date
    def potential_next(current, base)
      candidate = super(current, base)
      return candidate if (base.year - candidate.year).to_i % @interval == 0

      years = ((base.year - candidate.year).to_i % @interval)

      (candidate + years.years).beginning_of_year
    end

    def potential_previous(current, base)
      candidate = super(current, base)
      return candidate if (base.year - candidate.year).to_i % @interval == 0

      years = ((base.year - candidate.year).to_i % @interval)

      (candidate + (years - @interval).years).end_of_year
    end

    def align(time, base)
      day = (day_filters ? time.day : base.day)
      mon = (month_filters ? time.mon : base.mon)

      time = time.beginning_of_year + (mon - 1).months + (day - 1).days

      # compensate crossing DST barrier (oh my...)
      offset = time.beginning_of_day.utc_offset
      time = time.beginning_of_day + base.hour.hours + base.min.minutes + base.sec.seconds
      time += (offset - time.utc_offset)

      time
    end

    def day_filters
      filters(:weekdays) || filters(:monthdays) || filters(:yeardays)
    end

    def month_filters
      filters(:weekdays) || filters(:yeardays) || filters(:weeks) || filters(:months)
    end
  end
end
