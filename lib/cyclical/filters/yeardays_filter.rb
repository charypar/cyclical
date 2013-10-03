module Cyclical
  class YeardaysFilter

    attr_reader :yeardays

    def initialize(*yeardays)
      raise ArgumentError, "Specify at least one day of the month" if yeardays.empty?

      @yeardays = yeardays.sort
    end

    def match?(date)
      last = date.end_of_year.yday
      (@yeardays.include?(date.yday) || @yeardays.include?(date.yday - last - 1))
    end

    def step
      1.day
    end

    # FIXME - traverse the days directly
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
