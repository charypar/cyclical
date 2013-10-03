# encoding: utf-8
require 'spec_helper'

describe YearlyRule do
  describe "simple rule" do
    before do
      @rule = YearlyRule.new
    end

    it "should return one day as step" do
      @rule.step.should == 1.year
    end

    it "should give next date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @rule.next(Time.local(2010, 1, 1, 9, 30, 21), base).should == Time.local(2011, 1, 1, 9, 30, 21)
      @rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2011, 1, 1, 9, 30, 21)

      # align forward should include base time
      @rule.next(base, base).should == base + 1.year
    end

    it "should give previous date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2009, 1, 1, 9, 30, 21)
      @rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      # align back should exclude base time
      @rule.previous(base, base).should == Time.local(2009, 1, 1, 9, 30, 21)
    end

    it "should match dates" do
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2011, 1, 1, 9, 30)).should be_true

      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2011, 1, 1, 9, 29)).should_not be_true
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2011, 1, 2, 9, 30)).should_not be_true
      @rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2011, 2, 1, 9, 30)).should_not be_true
    end
  end

  describe "finite rules" do
    before do
      @rule = YearlyRule.new
    end

    it "should accept count and allow chaining" do
      @rule.count(10).should be_a(YearlyRule)
      @rule.count.should == 10
    end

    it "should accept stop time" do
      @rule.stop(Time.utc(2020, 1, 1)).should be_a(YearlyRule)
      @rule.stop.should == Time.utc(2020, 1, 1)
    end

    it "should report rule finiteness" do
      YearlyRule.new.count(5).should be_finite
      YearlyRule.new.stop(Time.utc(2020, 1, 1)).should be_finite

      YearlyRule.new.should_not be_finite
    end
  end

  describe "rule with interval" do
    before do
      @every_other_year_rule = YearlyRule.new(2)
      @every_ten_years_rule = YearlyRule.new(10)
    end

    it "should return corect step" do
      @every_other_year_rule.step.should == 2.years
      @every_ten_years_rule.step.should == 10.years
    end

    it "should find next date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_year_rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @every_ten_years_rule.next(Time.local(2010, 1, 1), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_year_rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2012, 1, 1, 9, 30, 21)
      @every_ten_years_rule.next(Time.local(2010, 1, 1, 10), base).should == Time.local(2020, 1, 1, 9, 30, 21)

      # align forward should include base time
      @every_other_year_rule.next(base, base).should == base + 2.years
      @every_ten_years_rule.next(base, base).should == base + 10.years
    end

    it "should find previous date" do
      base = Time.local(2010, 1, 1, 9, 30, 21)

      @every_other_year_rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2008, 1, 1, 9, 30, 21)
      @every_ten_years_rule.previous(Time.local(2010, 1, 1), base).should == Time.local(2000, 1, 1, 9, 30, 21)

      @every_other_year_rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)
      @every_ten_years_rule.previous(Time.local(2010, 1, 1, 10), base).should == Time.local(2010, 1, 1, 9, 30, 21)

      # align back should exclude base time
      @every_other_year_rule.previous(base, base).should == Time.local(2008, 1, 1, 9, 30, 21)
      @every_ten_years_rule.previous(base, base).should == Time.local(2000, 1, 1, 9, 30, 21)
    end

    it "should match dates" do
      # same year, same datetime
      @every_ten_years_rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should be_true
      @every_ten_years_rule.match?(Time.local(2010, 1, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should be_true

      # right year, same dattime
      @every_other_year_rule.match?(Time.local(2012, 1, 12, 9, 30), Time.local(2010, 1, 12, 9, 30)).should be_true
      @every_other_year_rule.match?(Time.local(2020, 1, 12, 9, 30), Time.local(2010, 1, 12, 9, 30)).should be_true

      # wrong year, same datetime
      @every_ten_years_rule.match?(Time.local(2011, 1, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should_not be_true
      @every_ten_years_rule.match?(Time.local(2015, 1, 1, 9, 30), Time.local(2010, 1, 1, 9, 30)).should_not be_true

      # right year, different datetime
      @every_other_year_rule.match?(Time.local(2012, 3, 8, 9, 20), Time.local(2010, 1, 12, 9, 30)).should_not be_true
      @every_other_year_rule.match?(Time.local(2020, 6, 21, 9, 35), Time.local(2010, 1, 12, 9, 30)).should_not be_true
    end
  end

  describe "rule with filters" do
    before do
      @base = Time.utc(2000, 1, 1, 9, 30, 21)
      @rule = Rule.yearly.months(1, 2).weekdays(1,3)
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
    it "should do a hash roundtrip" do
      h = Rule.yearly(5).to_hash
      restore = Rule.from_hash(h)

      restore.class.should == YearlyRule
      restore.interval.should == 5
      restore.step.should == 5.years
    end

    it "should do a hash roundtrip with count" do
      h = Rule.yearly.count(10).to_hash
      restore = Rule.from_hash(h)

      restore.count.should == 10
    end

    it "should do a hash roundtrip with stop" do
      h = Rule.yearly.stop(Time.local(2020, 10, 10)).to_hash
      restore = Rule.from_hash(h)

      restore.stop.should == Time.local(2020, 10, 10)
    end

    it "should do a hash roundtrip with weekdays filter" do
      h = Rule.yearly.weekdays(:mon, :tuesday).to_hash
      restore = Rule.from_hash(h)

      restore.filters(:weekdays).weekdays.should == [1, 2]
    end

    it "should do a hash roundtrip with ordered weekdays filter" do
      h = Rule.yearly.weekdays(:mon => 1, :tuesday => [2, -3]).to_hash
      restore = Rule.from_hash(h)

      restore.filters(:weekdays).ordered_weekdays.should == {:mo => [1], :tu => [-3, 2]}
    end

    it "should do a hash roundtrip with monthdays filter" do
      h = Rule.yearly.monthdays(1, 3, 7, -10).to_hash
      restore = Rule.from_hash(h)

      restore.filters(:monthdays).monthdays.should == [-10, 1, 3, 7]
    end

    it "should do a hash roundtrip with months filter" do
      h = Rule.yearly.months(1, 3, 12, -5).to_hash
      restore = Rule.from_hash(h)

      restore.filters(:months).months.should == [-5, 1, 3, 12]
    end

    it "should do a hash roundtrip with yeardays filter" do
      h = Rule.yearly.yeardays(1, 30, 120, -50).to_hash
      restore = Rule.from_hash(h)

      restore.filters(:yeardays).yeardays.should == [-50, 1, 30, 120]
    end
  end
end
