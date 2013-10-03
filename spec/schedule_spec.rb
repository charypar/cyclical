require 'spec_helper'

describe Schedule do
  it "should create instances with start date" do
    t = Time.now
    s = Schedule.new(t)

    s.start_time.should == t
  end

  # basic API for listing occurences
  describe "single date schedule" do
    before do
      @time = Time.local(2011, 11, 1, 0, 0, 0)
      @schedule = Schedule.new(@time)
    end

    it "should accept end time and return suboccurrence" do
      @schedule.end_time = Time.local(2011, 11, 1, 1)

      @schedule.end_time.should == Time.local(2011, 11, 1, 1)

      so = @schedule.suboccurrences_between(Time.local(2011, 11, 1, 0, 30), Time.local(2011, 11, 2))
      so.first.start.should == Time.local(2011, 11, 1, 0, 30)
      so.first.occurrence_start?.should_not be_true
      so.first.end.should == @schedule.end_time
      so.first.occurrence_end?.should be_true
    end

    it "should list the single occurrence" do
      @schedule.first(1).should include(Time.local(2011, 11, 1))
    end

    it "should find next occurrence" do
      t = Time.local(2011, 11, 1)

      @schedule.next_occurrence(t - 1.second).should == t
      @schedule.next_occurrence(t + 1.second).should be_nil

      @schedule.next_occurrence(t).should == t
    end

    it "should find previous occurrence" do
      t = Time.local(2011, 11, 1)

      @schedule.previous_occurrence(t + 1.second).should == t
      @schedule.previous_occurrence(t - 1.second).should be_nil

      @schedule.previous_occurrence(t).should be_nil
    end

    it "should list occurrences between dates" do
      t = Time.local(2011, 11, 1)

      @schedule.occurrences_between(t - 10.minutes, t - 1.second).should be_empty
      @schedule.occurrences_between(t + 1.second, t + 10.minutes).should be_empty

      @schedule.occurrences_between(t - 1.second, t + 1.second).should include(t)

      @schedule.occurrences_between(t - 10.minutes, t).should be_empty
      @schedule.occurrences_between(t, t + 10.minutes).should include(t)
    end

    it "should list occurrences up to a date" do
      t = Time.local(2011, 11, 1)

      @schedule.occurrences(t - 1.second).should be_empty
      @schedule.occurrences(t).should be_empty
      @schedule.occurrences(t + 1.second).should include(t)
    end

    it "should list all occurences" do
      @schedule.occurrences.should include(Time.local(2011, 11, 1))
    end
  end

  describe "advanced case" do
    before do
      @time = Time.local(2011, 9, 1, 10)
      @schedule = Schedule.new @time, Rule.monthly(2).weekdays(:mon => 2).count(5)
    end

    it "should list first 3 occurrences" do
      expected = [Time.local(2011, 9, 12, 10), Time.local(2011, 11, 14, 10), Time.local(2012, 1, 9, 10)]

      @schedule.first(3).should == expected
    end

    it "should find next occurrence" do
      @schedule.next_occurrence(Time.local(2011, 10, 1)).should == Time.local(2011, 11, 14, 10)
      @schedule.next_occurrence(Time.local(2011, 11, 14)).should == Time.local(2011, 11, 14, 10)
      @schedule.next_occurrence(Time.local(2011, 11, 14, 10)).should == Time.local(2011, 11, 14, 10)
      @schedule.next_occurrence(Time.local(2011, 11, 14, 10, 0, 1)).should == Time.local(2012, 1, 9, 10)
    end

    it "should find previous occurrence" do
      @schedule.previous_occurrence(Time.local(2011, 12, 1)).should == Time.local(2011, 11, 14, 10)
      @schedule.previous_occurrence(Time.local(2011, 11, 14, 10, 0, 1)).should == Time.local(2011, 11, 14, 10)
      @schedule.previous_occurrence(Time.local(2011, 11, 14, 10)).should == Time.local(2011, 9, 12, 10)
    end

    it "should list occurrences between dates" do
      @schedule.occurrences_between(Time.local(2011, 10, 1), Time.local(2011, 11, 14, 10, 0, 1)).should include(Time.local(2011, 11, 14, 10))
      @schedule.occurrences_between(Time.local(2011, 11, 14, 10), Time.local(2011, 11, 14, 11)).should include(Time.local(2011, 11, 14, 10))

      @schedule.occurrences_between(Time.local(2011, 11, 14, 10, 0, 1), Time.local(2011, 12, 1)).should be_empty
      @schedule.occurrences_between(Time.local(2011, 11, 1), Time.local(2011, 11, 14, 10)).should be_empty
    end

    it "should list occurrences upto a date" do
      expected = [Time.local(2011, 9, 12, 10), Time.local(2011, 11, 14, 10), Time.local(2012, 1, 9, 10)]

      @schedule.occurrences(Time.local(2012, 1, 9, 10)).should == expected[0..1]
      @schedule.occurrences(Time.local(2012, 1, 9, 10, 0, 1)).should == expected
    end

    it "should list all occurrences" do
      expected = [Time.local(2011, 9, 12, 10), Time.local(2011, 11, 14, 10),
                  Time.local(2012, 1, 9, 10), Time.local(2012, 3, 12, 10), Time.local(2012, 5, 14, 10)]

      @schedule.occurrences.should == expected
    end
  end

  describe "multiple-day schedule" do
    before do
      @time = Time.local(2011, 11, 1, 15)
      @schedule = Schedule.new @time, Rule.daily(4).count(5)
      @schedule.end_time = Time.local(2011, 11, 3, 8) # two days later at 8 AM
    end

    it "should return single occurrence span between dates" do
      so = @schedule.suboccurrences_between(Time.local(2011, 11, 1), Time.local(2011, 11, 2))
      so.first.start.should == Time.local(2011, 11, 1, 15)
      so.first.end.should == Time.local(2011, 11, 2)
      so.first.occurrence_start?.should be_true
      so.first.occurrence_end?.should_not be_true

      so = @schedule.suboccurrences_between(Time.local(2011, 11, 1), Time.local(2011, 11, 3, 10))
      so.first.start.should == Time.local(2011, 11, 1, 15)
      so.first.end.should == Time.local(2011, 11, 3, 8)
      so.first.occurrence_start?.should be_true
      so.first.occurrence_end?.should be_true

      so = @schedule.suboccurrences_between(Time.local(2011, 11, 2, 5), Time.local(2011, 11, 3, 10))
      so.first.start.should == Time.local(2011, 11, 2, 5)
      so.first.end.should == Time.local(2011, 11, 3, 8)
      so.first.occurrence_start?.should_not be_true
      so.first.occurrence_end?.should be_true

      @schedule.suboccurrences_between(Time.local(2011, 11, 3, 9), Time.local(2011, 11, 4, 11)).should be_empty
    end

    it "should return multiple occurrence spans" do
      so = @schedule.suboccurrences_between(Time.local(2011, 11, 1), Time.local(2011, 11, 8))

      so.length.should == 2
      so.first.start.should == Time.local(2011, 11, 1, 15)
      so.first.end.should == Time.local(2011, 11, 3, 8)
      so.first.occurrence_start?.should be_true
      so.first.occurrence_end?.should be_true

      so[1].start.should == Time.local(2011, 11, 5, 15)
      so[1].end.should == Time.local(2011, 11, 7, 8)
      so[1].occurrence_start?.should be_true
      so[1].occurrence_end?.should be_true
    end
  end

  describe "self overlapping schedule" do
    before do
      @time = Time.local(2011, 11, 1, 15)
      @schedule = Schedule.new @time, Rule.daily.count(5)
      @schedule.end_time = Time.local(2011, 11, 3, 8) # two days later at 8 AM
    end

    it "should find two occurrences in a single day" do
      s = @schedule.suboccurrences_between(Time.local(2011, 11, 2), Time.local(2011, 11, 3))

      s.length.should == 2

      s.first.start.should == Time.local(2011, 11, 2)
      s.first.occurrence_start?.should_not be_true
      s.first.end.should == Time.local(2011, 11, 3)
      s.first.occurrence_end?.should_not be_true

      s.last.start.should == Time.local(2011, 11, 2, 15)
      s.last.occurrence_start?.should be_true
      s.last.end.should == Time.local(2011, 11, 3)
      s.last.occurrence_end?.should_not be_true
    end
  end

  # Examples from RFC 5545 except excluded and included dates
  describe "rfc 5545 examples" do
    before do
      @time = Time.local(1997, 9, 2, 9, 0, 0)
    end

    describe "daily for 10 occurrences" do
      before do
        @schedule = Schedule.new @time, Rule.daily.count(10)
      end

      it "should list occurences" do
        expected = (2..11).map { |i| Time.local(1997, 9, i, 9, 0, 0) }
        @schedule.occurrences.should == expected
      end
    end

    describe "daily until December 24, 1997" do
      before do
        @schedule = Schedule.new @time, Rule.daily.stop(Time.local(1997, 12, 24))
      end

      it "should list occurrences" do
        expected = (2..30).map { |i| Time.local(1997, 9, i, 9, 0, 0) } +
                   (1..31).map { |i| Time.local(1997, 10, i, 9, 0, 0) } +
                   (1..30).map { |i| Time.local(1997, 11, i, 9, 0, 0) } +
                   (1..23).map { |i| Time.local(1997, 12, i, 9, 0, 0) }

        @schedule.occurrences.should == expected
      end
    end

    describe "every other day - forever" do
      before do
        @schedule = Schedule.new @time, Rule.daily(2)
      end

      it "should list first 45 occurrences" do
        expected = (1..15).map { |i| Time.local(1997, 9, 2*i, 9, 0, 0)} +
                   (1..15).map { |i| Time.local(1997, 10, 2*i, 9, 0, 0)} +
                   (1..15).map { |i| Time.local(1997, 11, 2*i - 1, 9, 0, 0)}

        @schedule.first(45).should == expected
        @schedule.occurrences(Time.local(1997, 12, 1)).should == expected
      end
    end

    describe "every 10 days, 5 occurrences" do
      before do
        @schedule = Schedule.new @time, Rule.daily(10).count(5)
      end

      it "should list occurrences" do
        expected =  [2, 12, 22].map { |i| Time.local(1997, 9, i, 9, 0, 0)} +
                    [2, 12].map { |i| Time.local(1997, 10, i, 9, 0, 0)}

        @schedule.occurrences.should == expected
      end
    end

    describe "every day in January, for 3 years" do
      before do
        @schedule_1 = Schedule.new Time.local(1998, 1, 1, 9), Rule.daily.month(:january).stop(Time.local(2000, 1, 31, 14))

        rule = Rule.yearly.month(:january).weekdays(1, :tu, :we, :th, 5, 6, :su).stop(Time.local(2000, 1, 31, 14))
        @schedule_2 = Schedule.new Time.local(1998, 1, 1, 9), rule
      end

      it "should list occurrences" do
        expected = (1..31).map { |i| Time.local(1998, 1, i, 9) } +
                   (1..31).map { |i| Time.local(1999, 1, i, 9) } +
                   (1..31).map { |i| Time.local(2000, 1, i, 9) }

        @schedule_1.occurrences.length.should == expected.length
        @schedule_1.occurrences.should == expected

        @schedule_2.occurrences.length.should == expected.length
        @schedule_2.occurrences.should == expected
      end
    end

    describe "weekly for 10 occurrences" do
      before do
        @schedule = Schedule.new @time, Rule.weekly.count(10)
      end

      it "should list occurrences" do
        expected = [2, 9, 16, 23, 30].map { |i| Time.local(1997, 9, i, 9)} +
                   [7, 14, 21, 28].map { |i| Time.local(1997, 10, i, 9)} +
                   [4].map { |i| Time.local(1997, 11, i, 9)}

        @schedule.occurrences.should == expected
      end
    end

    describe "weekly until December 24, 1997" do
      before do
        @schedule = Schedule.new @time, Rule.weekly.stop(Time.local(1997, 12, 24))
      end

      it "should list occurrences" do
        expected = [2, 9, 16, 23, 30].map { |i| Time.local(1997, 9, i, 9) } +
                   [7, 14, 21, 28].map { |i| Time.local(1997, 10, i, 9) } +
                   [4, 11, 18, 25].map { |i| Time.local(1997, 11, i, 9) } +
                   [2, 9, 16, 23].map { |i| Time.local(1997, 12, i, 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "every other week forever" do
      before do
        @schedule = Schedule.new @time, Rule.weekly(2)
      end

      it "should list first 14 occurrences" do
        expected = [2, 16, 30].map { |i| Time.local(1997, 9, i, 9) } +
                   [14, 28].map { |i| Time.local(1997, 10, i, 9) } +
                   [11, 25].map { |i| Time.local(1997, 11, i, 9) } +
                   [9, 23].map { |i| Time.local(1997, 12, i, 9) } +
                   [6, 20].map { |i| Time.local(1998, 1, i, 9) } +
                   [3, 17].map { |i| Time.local(1998, 2, i, 9) }

        @schedule.first(13).should == expected
      end
    end

    describe "weekly on tuesday and thursday for five weeks" do
      before do
        @stop_schedule = Schedule.new @time, Rule.weekly.weekdays(:tue, :thu).stop(Time.local(1997, 10, 7))
        @count_schedule = Schedule.new @time, Rule.weekly.weekdays(:tue, :thu).count(10)
      end

      it "should list occurrences" do
        expected = [2, 4, 9, 11, 16, 18, 23, 25, 30].map { |i| Time.local(1997, 9, i, 9) } +
                   [2].map { |i| Time.local(1997, 10, i, 9) }

        @stop_schedule.occurrences.should == expected
        @count_schedule.occurrences.should == expected
      end
    end

    describe "every other week on Monday, Wednesday, and Friday until December 24, 1997" do
      # starting on Monday, September 1, 1997
      before do
        @time = Time.local(1997, 9, 1, 9)
        @schedule = Schedule.new @time, Rule.weekly(2).weekdays(:mon, :wed, :fri).stop(Time.local(1997, 12, 24))
      end

      it "should list occurrences" do
        expected = [1, 3, 5, 15, 17, 19, 29].map { |i| Time.local(1997, 9, i, 9) } +
                   [1, 3, 13, 15, 17, 27, 29, 31].map { |i| Time.local(1997, 10, i, 9) } +
                   [10, 12, 14, 24, 26, 28].map { |i| Time.local(1997, 11, i, 9) } +
                   [8, 10, 12, 22].map { |i| Time.local(1997, 12, i, 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "every other week on Tuesday and Thursday, for 8 occurrences" do
      before do
        @schedule = Schedule.new @time, Rule.weekly(2).weekdays(:tu, :th).count(8)
      end

      it "should list occurrences" do
        expected = [2, 4, 16, 18, 30].map { |i| Time.local(1997, 9, i, 9) } +
                   [2, 14, 16].map { |i| Time.local(1997, 10, i, 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "monthly on the first friday for 10 occurrences" do
      before do
        @schedule = Schedule.new @time, Rule.monthly.weekdays(:friday => 1).count(10)
      end

      it "should list occurrences" do
        expected = [[9, 5], [10, 3], [11, 7], [12, 5]].map {|d| Time.local(1997, d[0], d[1], 9) } +
                   [[1, 2], [2, 6], [3, 6], [4, 3], [5, 1], [6, 5]].map {|d| Time.local(1998, d[0], d[1], 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "monthly on the first friday until December 24, 1997" do
      before do
        @schedule = Schedule.new @time, Rule.monthly.weekdays(:friday => 1).stop(Time.local(1997, 12, 24))
      end

      it "should list occurrences" do
        expected = [[9, 5], [10, 3], [11, 7], [12, 5]].map {|d| Time.local(1997, d[0], d[1], 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "every other month on the first and last Sunday of the month for 10 occurrences" do
      before do
        @schedule = Schedule.new @time, Rule.monthly(2).weekdays(:sunday => [1, -1]).count(10)
      end

      it "should list occurrences" do
        expected = [[9, 7], [9, 28], [11, 2], [11, 30]].map {|d| Time.local(1997, d[0], d[1], 9) } +
                   [[1, 4], [1, 25], [3, 1], [3, 29], [5, 3], [5, 31]].map {|d| Time.local(1998, d[0], d[1], 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "monthly on the second-to-last monday of the month for 6 months" do
      before do
        @schedule = Schedule.new @time, Rule.monthly.weekdays(:monday => -2).count(6)
      end

      it "should list occurrences" do
        expected = [[9, 22], [10, 20], [11, 17], [12, 22]].map {|d| Time.local(1997, d[0], d[1], 9) } +
                   [[1, 19], [2, 16]].map {|d| Time.local(1998, d[0], d[1], 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "monthly on the third-to-the-last day of the month, forever" do
      before do
        @schedule = Schedule.new @time, Rule.monthly.monthday(-3)
      end

      it "should list 6 occurrences" do
        expected = [[9, 28], [10, 29], [11, 28], [12, 29]].map {|d| Time.local(1997, d[0], d[1], 9) } +
                   [[1, 29], [2, 26]].map {|d| Time.local(1998, d[0], d[1], 9) }

        @schedule.first(6).should == expected
      end
    end

    describe "monthly on the 2nd and 15th of the month for 10 occurrences" do
      before do
        @schedule = Schedule.new @time, Rule.monthly.monthdays(2, 15).count(10)
      end

      it "should list occurrences" do
        expected = [[9, 2], [9, 15], [10, 2], [10, 15], [11, 2], [11, 15], [12, 2], [12, 15]].map {|d| Time.local(1997, d[0], d[1], 9) } +
                   [[1, 2], [1, 15]].map {|d| Time.local(1998, d[0], d[1], 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "monthly on the first and last day of the month for 10 occurrences" do
      before do
        @schedule = Schedule.new @time, Rule.monthly.monthdays(1, -1).count(10)
      end

      it "should list occurrences" do
        expected = [[9, 30], [10, 1], [10, 31], [11, 1], [11, 30], [12, 1], [12, 31]].map {|d| Time.local(1997, d[0], d[1], 9) } +
                   [[1, 1], [1, 31], [2, 1]].map {|d| Time.local(1998, d[0], d[1], 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "every 18 months on the 10th thru 15th of the month for 10 occurrences" do
      before do
        @schedule = Schedule.new @time, Rule.monthly(18).monthdays(*(10..15).to_a).count(10)
      end

      it "should list occurrences" do
        expected = (10..15).map {|d| Time.local(1997, 9, d, 9) } +
                   (10..13).map {|d| Time.local(1999, 3, d, 9) }

        @schedule.occurrences.should == expected
      end
    end

    describe "every Tuesday, every other month" do
      before do
        @schedule = Schedule.new @time, Rule.monthly(2).weekdays(:tue)
      end

      it "should list 18 occurrences" do
        expected = [2, 9, 16, 23, 30].map {|d| Time.local(1997, 9, d, 9)} +
                   [4, 11, 18, 25].map {|d| Time.local(1997, 11, d, 9)} +
                   [6, 13, 20, 27].map {|d| Time.local(1998, 1, d, 9)} +
                   [3, 10, 17, 24, 31].map {|d| Time.local(1998, 3, d, 9)}

        @schedule.first(18).should == expected
      end
    end

    describe "yearly in June and July for 10 occurrences" do
      before do
        @schedule = Schedule.new Time.local(1997, 6, 10, 9), Rule.yearly.months(6, 7).count(10)
      end

      it "shoul lists occurrences" do
        expected = [1997, 1998, 1999, 2000, 2001].map {|y| [Time.local(y, 6, 10, 9), Time.local(y, 7, 10, 9)] }.flatten

        @schedule.occurrences.should == expected
      end
    end

    describe "every other year on January, February, and March for 10 occurrences" do
      before do
        @schedule = Schedule.new Time.local(1997, 3, 10, 9), Rule.yearly(2).months(1, 2, 3).count(10)
      end

      it "should list occurrences" do
        expected = [Time.local(1997, 3, 10, 9)] + [1999, 2001, 2003].map {|y| [1, 2, 3].map {|m| Time.local(y, m, 10, 9)}}.flatten

        @schedule.occurrences.should == expected
      end
    end

    describe "every third year on the 1st, 100th, and 200th day for 10 occurrences" do
      before do
        @schedule = Schedule.new Time.local(1997, 1, 1, 9), Rule.yearly(3).yeardays(1, 100, 200).count(10)
      end

      it "should list occurrences" do
        expected = [[1997, 1, 1, 9], [1997, 4, 10, 9], [1997, 7, 19, 9], [2000, 1, 1, 9], [2000, 4, 9, 9],
                    [2000, 7, 18, 9], [2003, 1, 1, 9], [2003, 4, 10, 9], [2003, 7, 19, 9], [2006, 1, 1, 9]].map {|d| Time.local(d[0], d[1], d[2], d[3])}

        @schedule.occurrences.should == expected
      end
    end

    describe "every 20th Monday of the year, forever" do
      before do
        @schedule = Schedule.new Time.local(1997, 5, 19, 9), Rule.yearly.weekdays(:mon => 20)
      end

      it "should list 3 occurrences" do
        expected = [Time.local(1997, 5, 19, 9), Time.local(1998, 5, 18, 9), Time.local(1999, 5, 17, 9)]

        @schedule.first(3).should == expected
      end
    end

    # skipped: Monday of week number 20 (where the default start of the week is Monday), forever

    describe "every Thursday in March, forever" do
      before do
        @schedule = Schedule.new Time.local(1997, 3, 13, 9), Rule.yearly.month(:march).weekday(:thursday)
      end

      it "should list 11 occurrences" do
        expected = [13, 20, 27].map {|d| Time.local(1997, 3, d, 9)} +
                   [5, 12, 19, 26].map {|d| Time.local(1998, 3, d, 9)} +
                   [4, 11, 18, 25].map {|d| Time.local(1999, 3, d, 9)}

        @schedule.first(11).should == expected
      end
    end

    describe "every Thursday, but only during June, July, and August, forever" do
      before do
        @schedule = Schedule.new Time.local(1997, 6, 5, 9), Rule.yearly.months(6, 7, 8).weekday(:thu)
      end

      it "should list first X occurrences" do
        expected = [5, 12, 19, 26].map {|d| Time.local(1997, 6, d, 9)} +
                   [3, 10, 17, 24, 31].map {|d| Time.local(1997, 7, d, 9)} +
                   [7, 14, 21, 28].map {|d| Time.local(1997, 8, d, 9)} +
                   [4, 11, 18, 25].map {|d| Time.local(1998, 6, d, 9)} +
                   [2, 9, 16, 23, 30].map {|d| Time.local(1998, 7, d, 9)} +
                   [6, 13, 20, 27].map {|d| Time.local(1998, 8, d, 9)} +
                   [3, 10, 17, 24].map {|d| Time.local(1999, 6, d, 9)} +
                   [1, 8, 15, 22, 29].map {|d| Time.local(1999, 7, d, 9)} +
                   [5, 12, 19, 26].map {|d| Time.local(1999, 8, d, 9)}

        @schedule.first(39).should == expected
      end
    end

    describe "every Friday the 13th, forever" do
      before do
        @schedule = Schedule.new Time.local(1997, 9, 2, 9), Rule.monthly.weekday(:fri).monthday(13)
      end

      it "should list 5 occurrences" do
        expected = [Time.local(1998, 2, 13, 9), Time.local(1998, 3, 13, 9), Time.local(1998, 11, 13, 9),
                    Time.local(1999, 8, 13, 9), Time.local(2000, 10, 13, 9)]

        @schedule.first(5).should == expected
      end
    end

    describe "the first Saturday that follows the first Sunday of the month, forever" do
      before do
        @schedule = Schedule.new Time.local(1997, 9, 13, 9), Rule.monthly.weekday(:sat).monthdays(*(7..13))
      end

      it "should list 10 occurrences" do
        expected = [[9, 13], [10, 11], [11, 8], [12, 13]].map { |d| Time.local(1997, d[0], d[1], 9) } +
                   [[1, 10], [2, 7], [3, 7], [4, 11], [5, 9], [6, 13]].map { |d| Time.local(1998, d[0], d[1], 9) }

        @schedule.first(10).should == expected
      end
    end

    describe "every 4 years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day):" do
      before do
        @schedule = Schedule.new Time.local(1996, 11, 5, 9), Rule.yearly(4).month(11).weekday(:tue).monthdays(*(2..8))
      end

      it "should list first 3 election days" do
        expected = [Time.local(1996, 11, 5, 9), Time.local(2000, 11, 7, 9), Time.local(2004, 11, 2, 9)]

        @schedule.first(3).should == expected
      end
    end

    # skipped most of the the rest - i.e. we're missing implementation of BYSETPOS and less-than-a-day recurrence rules

    describe "ignoring an invalid date (i.e., February 30)" do
      before do
        @schedule = Schedule.new Time.local(2007, 1, 15, 9), Rule.monthly.monthdays(15, 30).count(5)
      end

      it "should list occurrences" do
        expected = [[1, 15], [1, 30], [2, 15], [3, 15], [3, 30]].map {|d| Time.local(2007, d[0], d[1], 9) }

        @schedule.occurrences.should == expected
      end
    end
  end

  describe "serialization" do
    before do
      @schedule = Schedule.new(Time.local(2000, 1, 1, 10), Rule.monthly.monthdays(1).count(10))
      @schedule.end_time = (Time.local(2000, 1, 1, 10, 10))
    end

    it "should do a hash round trip" do
      h = @schedule.to_hash
      s = Schedule.from_hash(h)

      s.start_time.should == @schedule.start_time
      s.end_time.should == @schedule.end_time

      s.rule.class.should == @schedule.rule.class
      s.rule.step.should == @schedule.rule.step
    end

    it "should do a JSON round trip" do
      j = @schedule.to_json
      s = Schedule.from_json(j)

      s.start_time.should == @schedule.start_time
      s.end_time.should == @schedule.end_time

      s.rule.class.should == @schedule.rule.class
      s.rule.step.should == @schedule.rule.step
    end
  end
end
