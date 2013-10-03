# encoding: utf-8

require 'spec_helper'

describe MonthlyRule do
  describe "simple rule" do
    before do
      @rule = MonthlyRule.new
    end

    it "should return one day as step" do
      @rule.step.should == 1.month
    end

    it "should give next date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @rule.next(Time.local(2010, 1, 1, 9, 30, 21), base).should == Time.local(2010, 2, 1, 9, 30, 21)
      @rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 2, 1, 9, 30, 21)

      # align forward should include base time
      @rule.next(base, base).should == base + 1.month
    end

    it "should give previous date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2009, 12, 1, 9, 30, 21)
      @rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      # align back should exclude base time
      @rule.previous(base, base).should == Time.local(2009, 12, 1, 9, 30, 21)
    end

    it "should match dates" do
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should be_true

      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 1, 9, 29)).should_not be_true
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 8, 9, 30)).should_not be_true
    end
  end

  describe "finite rules" do
    before do
      @rule = MonthlyRule.new
    end

    it "should accept count and allow chaining" do
      @rule.count(10).should be_a(MonthlyRule)
      @rule.count.should == 10
    end

    it "should accept stop time" do
      @rule.stop(Time.utc(2020, 1, 1)).should be_a(MonthlyRule)
      @rule.stop.should == Time.utc(2020, 1, 1)
    end

    it "should report rule finiteness" do
      MonthlyRule.new.count(5).should be_finite
      MonthlyRule.new.stop(Time.utc(2020, 1, 1)).should be_finite

      MonthlyRule.new.should_not be_finite
    end
  end

  describe "rule with interval" do
    before do
      @every_other_month_rule = MonthlyRule.new(2)
      @every_ten_months_rule = MonthlyRule.new(10)
    end

    it "should return corect step" do
      @every_other_month_rule.step.should == 2.months
      @every_ten_months_rule.step.should == 10.months
    end

    it "should find next date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_month_rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @every_ten_months_rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_month_rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 3, 1, 9, 30, 21)
      @every_ten_months_rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 11, 1, 9, 30, 21)

      # align forward should include base time
      @every_other_month_rule.next(base, base).should == base + 2.months
      @every_ten_months_rule.next(base, base).should == base + 10.months
    end

    it "should find previous date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_month_rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2009, 11, 1, 9, 30, 21)
      @every_ten_months_rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2009, 3, 1, 9, 30, 21)

      @every_other_month_rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @every_ten_months_rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      # align back should exclude base time
      @every_other_month_rule.previous(base, base).should == Time.local(2009, 11, 1, 9, 30, 21)
      @every_ten_months_rule.previous(base, base).should == Time.local(2009, 3, 1, 9, 30, 21)
    end

    it "should match dates" do
      # same month, same datetime
      @every_ten_months_rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should be_true
      @every_ten_months_rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should be_true

      # right month, same dattime
      @every_other_month_rule.match?(Time.local(2010, 3, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should be_true
      @every_other_month_rule.match?(Time.local(2010, 11, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should be_true

      # wrong month, same datetime
      @every_ten_months_rule.match?(Time.local(2010, 2, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should_not be_true
      @every_ten_months_rule.match?(Time.local(2010, 8, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should_not be_true

      # right month, different datetime
      @every_other_month_rule.match?(Time.local(2010, 3, 8, 9, 20), Time.local(2010, 1, 1, 9, 30)).should_not be_true
      @every_other_month_rule.match?(Time.local(2010, 11, 21, 9, 35), Time.local(2010, 1, 1, 9, 30)).should_not be_true
    end
  end

  describe "rule with filters" do
    before do
      @base = Time.utc(2000, 1, 1, 9, 30, 21)
      @rule = Rule.monthly.months(1, 2).weekdays(1,3)
    end

    it "should find next date" do
      @rule.next(Time.utc(2000, 1, 1), @base).should == Time.utc(2000, 1, 3, 9, 30, 21)
      @rule.next(Time.utc(2000, 1, 3, 10), @base).should == Time.utc(2000, 1, 5, 9, 30, 21)

      @rule.next(Time.utc(2000, 2, 2), @base).should == Time.utc(2000, 2, 2, 9, 30, 21)
      @rule.next(Time.utc(2000, 2, 2, 10), @base).should == Time.utc(2000, 2, 7, 9, 30, 21)
      @rule.next(Time.utc(2000, 2, 29), @base).should == Time.utc(2001, 1, 1, 9, 30, 21)
      @rule.next(Time.utc(2000, 3, 1), @base).should == Time.utc(2001, 1, 1, 9, 30, 21)
    end

    it "should find previous date" do
      @rule.previous(Time.utc(2000, 1, 1), @base).should == Time.utc(1999, 2, 24, 9, 30, 21)
      @rule.previous(Time.utc(2000, 1, 3, 10), @base).should == Time.utc(2000, 1, 3, 9, 30, 21)

      @rule.previous(Time.utc(2000, 2, 2), @base).should == Time.utc(2000, 1, 31, 9, 30, 21)
      @rule.previous(Time.utc(2000, 2, 2, 10), @base).should == Time.utc(2000, 2, 2, 9, 30, 21)
      @rule.previous(Time.utc(2000, 3, 3), @base).should == Time.utc(2000, 2, 28, 9, 30, 21)
      @rule.previous(Time.utc(2000, 3, 1), @base).should == Time.utc(2000, 2, 28, 9, 30, 21)
    end

    it "should match dates" do
      # weekdays match
      @rule.match?(Time.utc(2000, 1, 3, 9, 30, 21), @base).should be_true
      @rule.match?(Time.utc(2000, 1, 5, 9, 30, 21), @base).should be_true

      @rule.match?(Time.utc(2000, 1, 4, 9, 30, 21), @base).should_not be_true
      @rule.match?(Time.utc(2000, 1, 6, 9, 30, 21), @base).should_not be_true

      # months match
      @rule.match?(Time.utc(2000, 2, 23, 9, 30, 21), @base).should be_true
      @rule.match?(Time.utc(2000, 2, 2, 9, 30, 21), @base).should be_true

      @rule.match?(Time.utc(2000, 3, 3, 9, 30, 21), @base).should_not be_true
      @rule.match?(Time.utc(2000, 3, 4, 9, 30, 21), @base).should_not be_true

      # wrong time
      @rule.match?(Time.utc(2000, 1, 3, 9, 30, 28), @base).should_not be_true
      @rule.match?(Time.utc(2000, 1, 3, 9, 12, 29), @base).should_not be_true
      @rule.match?(Time.utc(2000, 1, 3, 10, 30, 29), @base).should_not be_true
    end
  end

  describe "serialization" do
    it "should do a simple hash roundtrip" do
      h = Rule.monthly(5).to_hash
      restore = Rule.from_hash(h)

      restore.class.should == MonthlyRule
      restore.interval.should == 5
      restore.step.should == 5.months
    end

    it "should do a hash roundtrip with count" do
      h = Rule.monthly.count(10).to_hash
      restore = Rule.from_hash(h)

      restore.count.should == 10
    end

    it "should do a hash roundtrip with stop" do
      h = Rule.monthly.stop(Time.local(2020, 10, 10)).to_hash
      restore = Rule.from_hash(h)

      restore.stop.should == Time.local(2020, 10, 10)
    end

    it "should do a hash roundtrip with weekdays filter" do
      h = Rule.monthly.weekdays(:mon, :tuesday).to_hash
      restore = Rule.from_hash(h)

      restore.filters(:weekdays).weekdays.should == [1, 2]
    end

    it "should do a hash roundtrip with ordered weekdays filter" do
      h = Rule.monthly.weekdays(:mon => 1, :tuesday => [2, -3]).to_hash
      restore = Rule.from_hash(h)

      restore.filters(:weekdays).ordered_weekdays.should == {:mo => [1], :tu => [-3, 2]}
    end

    it "should do a hash roundtrip with monthdays filter" do
      h = Rule.monthly.monthdays(1, 3, 7, -10).to_hash
      restore = Rule.from_hash(h)

      restore.filters(:monthdays).monthdays.should == [-10, 1, 3, 7]
    end
  end
end
