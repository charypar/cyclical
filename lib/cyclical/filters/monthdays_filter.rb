module Cyclical
  class MonthdaysFilter

    attr_reader :monthdays

    def initialize(*monthdays)
      raise ArgumentError, "Specify at least one day of the month" if monthdays.empty?

      @monthdays = monthdays.sort
    end

    def match?(date)
      last = date.end_of_month.day
      (@monthdays.include?(date.day) || @monthdays.include?(date.day - last - 1))
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
  end
end
