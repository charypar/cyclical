require 'spec_helper'

describe WeekdaysFilter do
  before do
    @filter = WeekdaysFilter.new(:monday, :tue, 5)
  end

  it "should accept weekdays as constructor arguments" do
    @filter.weekdays.should == [1, 2, 5]
  end

  it "should accept weekdays with order as well" do
    rule = MonthlyRule.new
    filter = WeekdaysFilter.new(rule, :tue, :monday => 1, :tuesday => [1, -1])

    filter.weekdays.should == [2]
    filter.ordered_weekdays.should == {:mo => [1], :tu => [-1, 1]}
  end

  it "should match only the selected weekdays" do
    filter = WeekdaysFilter.new(:mon, :fri)

    filter.match?(Time.utc(2000, 1, 3)).should be_true
    filter.match?(Time.utc(2000, 1, 7)).should be_true
    filter.match?(Time.utc(2000, 1, 10)).should be_true

    filter.match?(Time.utc(2000, 1, 2)).should be_false
    filter.match?(Time.utc(2000, 1, 4)).should be_false
    filter.match?(Time.utc(2000, 1, 5)).should be_false
    filter.match?(Time.utc(2000, 1, 6)).should be_false
    filter.match?(Time.utc(2000, 1, 8)).should be_false
    filter.match?(Time.utc(2000, 1, 9)).should be_false
  end

  it "should provide next valid date" do
    @filter.next(Time.utc(2010, 1, 1, 21, 13, 11)).should == Time.utc(2010, 1, 1, 21, 13, 11)
    @filter.next(Time.utc(2010, 1, 2, 21, 13, 11)).should == Time.utc(2010, 1, 4, 21, 13, 11)
    @filter.next(Time.utc(2010, 1, 4, 21, 13, 11)).should == Time.utc(2010, 1, 4, 21, 13, 11)
    @filter.next(Time.utc(2010, 1, 5, 21, 13, 11)).should == Time.utc(2010, 1, 5, 21, 13, 11)
    @filter.next(Time.utc(2010, 1, 6, 21, 13, 11)).should == Time.utc(2010, 1, 8, 21, 13, 11)
  end

  describe "with MonthlyRule" do
    before do
      rule = MonthlyRule.new
      @filter = WeekdaysFilter.new(rule, :mon => [-1, 1])
    end

    it "should store the rule" do
      @filter.rule.should be_a(MonthlyRule)
    end

    it "should match ordered weekdays" do
      # January
      # wrong weekday
      @filter.match?(Time.utc(2000, 1, 1)).should be_false
      @filter.match?(Time.utc(2000, 1, 2)).should be_false

      # right day right order
      @filter.match?(Time.utc(2000, 1, 3)).should be_true
      @filter.match?(Time.utc(2000, 1, 31)).should be_true

      # right day wrong order
      @filter.match?(Time.utc(2000, 1, 10)).should be_false
      @filter.match?(Time.utc(2000, 1, 17)).should be_false
      @filter.match?(Time.utc(2000, 1, 24)).should be_false

      # February
      # wrong weekday
      @filter.match?(Time.utc(2000, 2, 1)).should be_false
      @filter.match?(Time.utc(2000, 2, 2)).should be_false

      # right day right order
      @filter.match?(Time.utc(2000, 2, 7)).should be_true
      @filter.match?(Time.utc(2000, 2, 28)).should be_true

      # right day wrong order
      @filter.match?(Time.utc(2000, 2, 14)).should be_false
      @filter.match?(Time.utc(2000, 2, 21)).should be_false
    end
  end

  describe "with YearlyRule" do
    before do
      rule = YearlyRule.new
      @filter = WeekdaysFilter.new(rule, :mon => [-1, 1])
    end

    it "should store the rule" do
      @filter.rule.should be_a(YearlyRule)
    end

    it "should match ordered weekdays" do
      # wrong weekday
      @filter.match?(Time.utc(2000, 1, 1)).should be_false
      @filter.match?(Time.utc(2000, 1, 2)).should be_false

      # right day right order
      @filter.match?(Time.utc(2000, 1, 3)).should be_true
      @filter.match?(Time.utc(2000, 12, 25)).should be_true

      # right day wrong order
      @filter.match?(Time.utc(2000, 1, 10)).should be_false
      @filter.match?(Time.utc(2000, 1, 17)).should be_false
      @filter.match?(Time.utc(2000, 1, 24)).should be_false
    end
  end
end
