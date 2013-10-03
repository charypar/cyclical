require 'spec_helper'

describe WeeklyRule do
  describe "simple rule" do
    before do
      @rule = WeeklyRule.new
    end

    it "should return one week as step" do
      @rule.step.should == 1.week
    end

    it "should find next date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @rule.next(Time.local(2010, 1, 1, 9, 30, 21), base).should == Time.local(2010, 1, 8, 9, 30, 21)
      @rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 8, 9, 30, 21)

      # align forward should include base time
      @rule.next(base, base).should == base + 1.week
    end

    it "should find previous date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2009, 12, 25, 9, 30, 21)
      @rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      # align back should exclude base time
      @rule.previous(base, base).should == Time.local(2009, 12, 25, 9, 30, 21)
    end

    it "should match dates" do
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 8, 9, 30)).should be_true
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 15, 9, 30)).should be_true

      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 8, 9, 29)).should_not be_true
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 8, 10, 30)).should_not be_true
    end
  end

  describe "finite rules" do
    before do
      @rule = WeeklyRule.new
    end

    it "should accept count and allow chaining" do
      @rule.count(10).should be_a(WeeklyRule)
      @rule.count.should == 10
    end

    it "should accept stop time" do
      @rule.stop(Time.utc(2020, 1, 1)).should be_a(WeeklyRule)
      @rule.stop.should == Time.utc(2020, 1, 1)
    end

    it "should report rule finiteness" do
      WeeklyRule.new.count(5).should be_finite
      WeeklyRule.new.stop(Time.utc(2020, 1, 1)).should be_finite

      WeeklyRule.new.should_not be_finite
    end
  end

  describe "rule with interval" do
    before do
      @every_other_week_rule = WeeklyRule.new(2)
      @every_ten_weeks_rule = WeeklyRule.new(10)
    end

    it "should return corect step" do
      @every_other_week_rule.step.should == 2.weeks
      @every_ten_weeks_rule.step.should == 10.weeks
    end

    it "should find next date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_week_rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @every_ten_weeks_rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_week_rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 15, 9, 30, 21)
      @every_ten_weeks_rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 3, 12, 9, 30, 21)

      # align forward should include base time
      @every_other_week_rule.next(base, base).should == base + 2.weeks
      @every_ten_weeks_rule.next(base, base).should == base + 10.weeks
    end

    it "should align dates back" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_week_rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2009, 12, 18, 9, 30, 21)
      @every_ten_weeks_rule.previous(Time.local(2010, 1, 1), base).localtime.should == Time.local(2009, 10, 23, 9, 30, 21)

      @every_other_week_rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @every_ten_weeks_rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      # align forward should include base time
      @every_other_week_rule.previous(base, base).should == base - 2.weeks
      @every_ten_weeks_rule.previous(base, base).should == base - 10.weeks
    end

    it "should check date alignment" do
      base = Time.local(2010, 1, 1, 9, 30)

      @every_other_week_rule.match?(Time.local(2010, 1, 1, 9, 30), base).should be_true
      @every_other_week_rule.match?(Time.local(2010, 1, 15, 9, 30), base).should be_true

      @every_ten_weeks_rule.match?(Time.local(2010, 1, 1, 9, 30), base).should be_true
      @every_ten_weeks_rule.match?(Time.local(2010, 3, 12, 9, 30), base).should be_true

      @every_other_week_rule.match?(Time.local(2010, 1, 2, 9, 30), base).should_not be_true
      @every_ten_weeks_rule.match?(Time.local(2010, 1, 5, 9, 30), base).should_not be_true
    end
  end

  describe "serialization" do
    it "should do a simple hash roundtrip" do
      h = Rule.weekly(5).to_hash
      restore = Rule.from_hash(h)

      restore.class.should == WeeklyRule
      restore.interval.should == 5
      restore.step.should == 5.weeks
    end

    it "should do a hash roundtrip with count" do
      h = Rule.weekly.count(10).to_hash
      restore = Rule.from_hash(h)

      restore.count.should == 10
    end

    it "should do a hash roundtrip with stop" do
      h = Rule.weekly.stop(Time.local(2020, 10, 10)).to_hash
      restore = Rule.from_hash(h)

      restore.stop.should == Time.local(2020, 10, 10)
    end

    it "should do a hash roundtrip with weekdays filter" do
      h = Rule.weekly.weekdays(:mon, :tuesday).to_hash
      restore = Rule.from_hash(h)

      restore.filters(:weekdays).weekdays.should == [1, 2]
    end
  end
end
