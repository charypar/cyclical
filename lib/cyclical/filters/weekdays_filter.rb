module Cyclical
  class WeekdaysFilter

    WEEKDAYS = {
      :su => 0, :sun => 0, :sunday => 0,
      :mo => 1, :mon => 1, :monday => 1,
      :tu => 2, :tue => 2, :tuesday => 2,
      :we => 3, :wed => 3, :wednesday => 3,
      :th => 4, :thu => 4, :thursday => 4,
      :fr => 5, :fri => 5, :friday => 5,
      :sa => 6, :sat => 6, :saturday => 6
    }

    WEEKDAY_NAMES = [:su, :mo, :tu, :we, :th, :fr, :sa]

    attr_reader :weekdays, :ordered_weekdays, :rule

    def initialize(*weekdays)
      @rule = weekdays.shift if weekdays.first.is_a?(Rule)

      raise ArgumentError, "Specify at least one weekday" if weekdays.empty?
      @ordered_weekdays = {}

      if weekdays.last.respond_to?(:has_key?)
        raise ArgumentError, "No recurrence rule given for ordered weekdays filter" if @rule.nil?

        weekdays.last.each do |day, orders|
          day = day.is_a?(Integer) ? day : WEEKDAYS[day]
          orders = [orders] unless orders.respond_to?(:each)

          @ordered_weekdays[WEEKDAY_NAMES[day]] = orders.sort
        end
        weekdays = weekdays[0..-2]
      end

      @weekdays = weekdays.map { |w| w.is_a?(Integer) ? w : WEEKDAYS[w.to_sym] }.sort
    end

    def match?(date)
      return true if weekdays.include?(date.wday)

      day = WEEKDAY_NAMES[date.wday]
      return false if ordered_weekdays[day].nil?

      first, occ, max = order_in_interval(date)

      return (ordered_weekdays[day].include?(occ) || ordered_weekdays[day].include?(occ - max - 1))
    end

    def step
      1.day
    end

    # FIXME - this can probably be calculated
    def next(date)
      until match?(date)
        date += 1.day
      end

      date
    end

    def previous(date)
      until match?(date)
        date -= 1.day
      end

      date
    end

    private

    def order_in_interval(date)
      case @rule
      when YearlyRule
        first = (7 + date.wday - date.beginning_of_year.wday) % 7 + 1
        occ = (date.yday - first) / 7 + 1
        max = (date.end_of_year.yday - first) / 7 + 1
      when MonthlyRule
        first = (7 + date.wday - date.beginning_of_month.wday) % 7 + 1
        occ = (date.day - first) / 7 + 1
        max = (date.end_of_month.day - first) / 7 + 1
      else
        raise RuntimeError, "Ordered weekdays filter only supports monthy and yearly rules. (#{@rule.class} given)"
      end

      [first, occ, max]
    end
  end
end
