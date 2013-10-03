module Cyclical
  class MonthsFilter

    MONTH_NAMES = {
      :jan => 1, :january => 1,
      :feb => 2, :february => 2,
      :mar => 3, :march => 3,
      :apr => 4, :april => 4,
      :may => 5,
      :jun => 6, :june => 6,
      :jul => 7, :july => 7,
      :aug => 8, :august => 8,
      :sep => 9, :sept => 9, :september => 9,
      :oct => 10, :october => 10,
      :nov => 11, :november => 11,
      :dec => 12, :december => 12
    }

    attr_reader :months

    def initialize(*months)
      raise ArgumentError, "Specify at least one month" if months.empty?

      @months = months.map { |m| m.is_a?(Integer) ? m : MONTH_NAMES[m.to_sym] }.sort
    end

    def match?(date)
      @months.include?(date.mon)
    end

    def step
      1.month
    end

    def next(date)
      return date if match?(date)

      if month = @months.find { |m| m > date.month }
        date.beginning_of_year + (month - 1).months + date.hour.hours + date.min.minutes + date.sec.seconds
      else
        date.beginning_of_year + 1.year + (@months.first - 1).months + date.hour.hours + date.min.minutes + date.sec.seconds
      end
    end

    def previous(date)
      return date if match?(date)

      if month = @months.reverse.find { |m| m < date.month }
        date.beginning_of_year + month.months - 1.day + date.hour.hours + date.min.minutes + date.sec.seconds
      else
        date.beginning_of_year - 1.year + @months.last.months - 1.day + date.hour.hours + date.min.minutes + date.sec.seconds
      end
    end
  end
end
