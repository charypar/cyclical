require 'spec_helper'

describe Rule do
  describe "rule factories" do
    it "should create daily rule" do
      Rule.daily.should be_a(DailyRule)

      rule = Rule.daily(5)
      rule.should be_a(DailyRule)
      rule.interval.should == 5
    end

    it "should create yearly dule" do
      Rule.yearly.should be_a(YearlyRule)

      rule = Rule.yearly(5)
      rule.should be_a(YearlyRule)
      rule.interval.should == 5
    end

    it "should create weekly rule" do
      Rule.weekly.should be_a(WeeklyRule)

      rule = Rule.weekly(5)
      rule.should be_a(WeeklyRule)
      rule.interval.should == 5
    end

    it "should create monthly rule" do
      Rule.monthly.should be_a(MonthlyRule)

      rule = Rule.monthly(5)
      rule.should be_a(MonthlyRule)
      rule.interval.should == 5
    end
  end

  describe "filters" do
    before :each do
      @rule = Rule.daily
    end

    it "should add single month filter and allow chaining" do
      @rule.month(:january).should be_a(DailyRule)
      @rule.filters.first.should be_a(MonthsFilter)

      @rule.filters(:months).should_not be_nil
      @rule.filters(:months).months.should == [1]
    end

    it "should add multiple months filter and allow chaining" do
      @rule.months(:january, :march, 5).should be_a(DailyRule)
      @rule.filters.first.should be_a(MonthsFilter)

      @rule.filters(:months).should_not be_nil
      @rule.filters(:months).months.should == [1, 3, 5]
    end

    it "should add single weekday filter and allow chaining" do
      @rule.weekday(:mon).should be_a(DailyRule)
      @rule.filters.first.should be_a(WeekdaysFilter)

      @rule.filters(:weekdays).should_not be_nil
      @rule.filters(:weekdays).weekdays.should == [1]
    end

    it "should add multiple weekdays filter and allow chaining" do
      @rule.weekdays(:monday, :tue, 3).should be_a(DailyRule)
      @rule.filters.first.should be_a(WeekdaysFilter)

      @rule.filters(:weekdays).should_not be_nil
      @rule.filters(:weekdays).weekdays.should == [1, 2, 3]
    end

    it "should pass rules into weekdays filter" do
      @rule.weekdays(:monday, :tue, 3).should be_a(DailyRule)

      @rule.filters(:weekdays).rule.should be_a(DailyRule)
    end

    it "should add monthday filter and allow chaining" do
      @rule.monthday(28).should be_a(DailyRule)
      @rule.filters.first.should be_a(MonthdaysFilter)

      @rule.filters(:monthdays).should_not be_nil
      @rule.filters(:monthdays).monthdays.should == [28]
    end

    it "should add monthday filter and allow chaining" do
      @rule.monthday(-20, 13, 25).should be_a(DailyRule)
      @rule.filters.first.should be_a(MonthdaysFilter)

      @rule.filters(:monthdays).should_not be_nil
      @rule.filters(:monthdays).monthdays.should == [-20, 13, 25]
    end

    it "should add multiple yeardays filter and allow chaining" do
      @rule.yeardays(-30, 100, 250).should be_a(DailyRule)
      @rule.filters.first.should be_a(YeardaysFilter)

      @rule.filters(:yeardays).should_not be_nil
      @rule.filters(:yeardays).yeardays.should == [-30, 100, 250]
    end
  end
end
