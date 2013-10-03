require 'spec_helper'

describe DailyRule do
  describe "simple rule" do
    before do
      @rule = DailyRule.new
    end

    it "should return one day as step" do
      @rule.step.should == 1.day
    end

    it "should find next date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @rule.next(Time.local(2010, 1, 1, 9, 30, 21), base).should == Time.local(2010, 1, 2, 9, 30, 21)
      @rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 2, 9, 30, 21)

      # align forward should include base time
      @rule.next(base, base).should == base + 1.day
    end

    it "should find previous date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2009, 12, 31, 9, 30, 21)
      @rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      # align back should exclude base time
      @rule.previous(base, base).should == Time.local(2009, 12, 31, 9, 30, 21)
    end

    it "should match dates" do
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 12, 9, 30)).should be_true
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 12, 9, 29)).should_not be_true
    end
  end

  describe "finite rules" do
    before do
      @rule = DailyRule.new
    end

    it "should accept count and allow chaining" do
      @rule.count(10).should be_a(DailyRule)
      @rule.count.should == 10
    end

    it "should accept stop time" do
      @rule.stop(Time.utc(2020, 1, 1)).should be_a(DailyRule)
      @rule.stop.should == Time.utc(2020, 1, 1)
    end

    it "should report rule finiteness" do
      DailyRule.new.count(5).should be_finite
      DailyRule.new.stop(Time.utc(2020, 1, 1)).should be_finite

      DailyRule.new.should_not be_finite
    end
  end

  describe "rule with interval" do
    before do
      @every_other_day_rule = DailyRule.new(2)
      @every_ten_days_rule = DailyRule.new(10)
    end

    it "should return corect step" do
      @every_other_day_rule.step.should == 2.days
      @every_ten_days_rule.step.should == 10.days
    end

    it "should find next date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_day_rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @every_ten_days_rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_day_rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 3, 9, 30, 21)
      @every_ten_days_rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 11, 9, 30, 21)

      # align forward should include base time
      @every_other_day_rule.next(base, base).should == base + 2.days
      @every_ten_days_rule.next(base, base).should == base + 10.days
    end

    it "should align dates back" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_day_rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2009, 12, 30, 9, 30, 21)
      @every_ten_days_rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2009, 12, 22, 9, 30, 21)

      @every_other_day_rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @every_ten_days_rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      # align forward should include base time
      @every_other_day_rule.previous(base, base).should == base - 2.days
      @every_ten_days_rule.previous(base, base).should == base - 10.days
    end

    it "should check date alignment" do
      base = Time.local(2010, 1, 1, 9, 30)

      @every_other_day_rule.match?(Time.local(2010, 1, 1, 9, 30), base).should be_true
      @every_other_day_rule.match?(Time.local(2010, 1, 3, 9, 30), base).should be_true

      @every_ten_days_rule.match?(Time.local(2010, 1, 1, 9, 30), base).should be_true
      @every_ten_days_rule.match?(Time.local(2010, 1, 11, 9, 30), base).should be_true

      @every_other_day_rule.match?(Time.local(2010, 1, 2, 9, 30), base).should_not be_true
      @every_ten_days_rule.match?(Time.local(2010, 1, 5, 9, 30), base).should_not be_true
    end
  end

  describe "serialization" do
    it "should do a simple hash roundtrip" do
      h = Rule.daily(5).to_hash
      restore = Rule.from_hash(h)

      restore.class.should == DailyRule
      restore.interval.should == 5
      restore.step.should == 5.days
    end

    it "should do a hash roundtrip with count" do
      h = Rule.daily.count(10).to_hash
      restore = Rule.from_hash(h)

      restore.count.should == 10
    end

    it "should do a hash roundtrip with stop" do
      h = Rule.daily.stop(Time.local(2020, 10, 10)).to_hash
      restore = Rule.from_hash(h)

      restore.stop.should == Time.local(2020, 10, 10)
    end
  end
end
