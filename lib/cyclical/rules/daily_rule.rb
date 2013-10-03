require 'cyclical/rule'

module Cyclical
  # holds daily rule configuration
  class DailyRule < Rule

    def aligned?(time, base)
      return false unless (base.to_date - time.to_date) % @interval == 0
      return false unless [time.hour, time.min, time.sec] == [base.hour, base.min, base.sec]

      true
    end

    def step
      @interval.days
    end

    protected

    def potential_next(current, base)
      candidate = super(current, base)

      rem = (base.to_date - candidate.to_date) % @interval

      return candidate if rem == 0

      rem += @interval if rem < 0
      candidate.beginning_of_day + rem.days
    end

    def potential_previous(current, base)
      candidate = super(current, base)

      rem = (base.to_date - candidate.to_date) % @interval

      return candidate if rem == 0

      rem += @interval if rem < 0
      candidate.beginning_of_day + (rem - @interval).days
    end

    def align(time, base)
      # compensate crossing DST barrier (oh my...)
      offset = time.beginning_of_day.utc_offset
      time = time.beginning_of_day + base.hour.hours + base.min.minutes + base.sec.seconds
      time += (offset - time.utc_offset)
    end
  end
end
