require 'spec_helper'

describe Occurrence do
  before do
    @start_time = Time.utc(2000, 1, 1, 9, 30)
    @occurrence = Occurrence.new(Rule.daily, @start_time)
  end

  it "should have read only rule attribute" do
    @occurrence.rule.should be_a(Rule)
  end

  it "should find next occurrence" do
    # simple cases
    @occurrence.next_occurrence(Time.utc(2010, 1, 1)).should == Time.utc(2010, 1, 1, 9, 30)
    @occurrence.next_occurrence(Time.utc(2010, 1, 1, 10)).should == Time.utc(2010, 1, 2, 9, 30)

    # boundary cases
    @occurrence.next_occurrence(Time.utc(2010, 1, 1, 9, 30)).should == Time.utc(2010, 1, 1, 9, 30)
    @occurrence.next_occurrence(@start_time).should == @start_time

    # limit case
    @occurrence.next_occurrence(@start_time).should == @start_time
    @occurrence.next_occurrence(Time.utc(1990, 1, 1)).should == @start_time
  end

  it "should find next n occurrences" do
    # simple cases
    expected = [Time.utc(2010, 1, 1, 9, 30), Time.utc(2010, 1, 2, 9, 30), Time.utc(2010, 1, 3, 9, 30), Time.utc(2010, 1, 4, 9, 30)]
    first_three = [@start_time, @start_time + 1.day, @start_time + 2.days]

    @occurrence.next_occurrences(3, Time.utc(2010, 1, 1)).should == expected[0..2]
    @occurrence.next_occurrences(3, Time.utc(2010, 1, 1, 10)).should == expected[1..3]

    # boundary cases
    @occurrence.next_occurrences(3, Time.utc(2010, 1, 1, 9, 30)).should == expected[0..2]
    @occurrence.next_occurrences(3, @start_time).should == first_three

    # limit case
    @occurrence.next_occurrences(3, @start_time).should == first_three
    @occurrence.next_occurrences(3, Time.utc(1990, 1, 1)).should == first_three

    # other lengths
    @occurrence.next_occurrences(5, Time.utc(2010, 1, 1)).length.should == 5
    @occurrence.next_occurrences(15, Time.utc(2010, 1, 1)).length.should == 15
  end

  it "should find previous occurrence" do
    base = Time.utc(2000, 1, 1, 9, 30)

    # simple cases
    @occurrence.previous_occurrence(Time.utc(2010, 1, 1)).should == Time.utc(2009, 12, 31, 9, 30)
    @occurrence.previous_occurrence(Time.utc(2010, 1, 1, 10)).should == Time.utc(2010, 1, 1, 9, 30)

    # boundary cases
    @occurrence.previous_occurrence(Time.utc(2010, 1, 1, 9, 30)).should == Time.utc(2009, 12, 31, 9, 30)

    # limit cases
    @occurrence.previous_occurrence(@start_time).should == nil
    @occurrence.previous_occurrence(Time.utc(1990, 1, 1)).should == nil
  end

  it "should find previous n occurrences" do
    # simple cases
    expected = [Time.utc(2009, 12, 29, 9, 30), Time.utc(2009, 12, 30, 9, 30), Time.utc(2009, 12, 31, 9, 30), Time.utc(2010, 1, 1, 9, 30)]

    # simple cases
    @occurrence.previous_occurrences(3, Time.utc(2010, 1, 1)).should == expected[0..2]
    @occurrence.previous_occurrences(3, Time.utc(2010, 1, 1, 10)).should == expected[1..3]

    # boundary cases
    @occurrence.previous_occurrences(3, Time.utc(2010, 1, 1, 9, 30)).should == expected[0..2]

    # limit case
    @occurrence.previous_occurrences(3, @start_time).should be_empty
    @occurrence.previous_occurrences(3, Time.utc(1990, 1, 1)).should be_empty

    # other lengths
    @occurrence.previous_occurrences(5, Time.utc(2010, 1, 1)).length.should == 5
    @occurrence.previous_occurrences(15, Time.utc(2010, 1, 1)).length.should == 15
  end

  it "should find occurrences between dates" do
    expected = [Time.utc(2010, 1, 1, 9, 30), Time.utc(2010, 1, 2, 9, 30), Time.utc(2010, 1, 3, 9, 30), Time.utc(2010, 1, 4, 9, 30)]

    # simple cases
    @occurrence.occurrences_between(Time.utc(2010, 1, 1), Time.utc(2010, 1, 4, 10)).should == expected
    @occurrence.occurrences_between(Time.utc(2010, 1, 1, 10), Time.utc(2010, 1, 4, 10)).should == expected[1..3]
    @occurrence.occurrences_between(Time.utc(2010, 1, 1), Time.utc(2010, 1, 4, 0)).should == expected[0..2]

    # boundary cases
    @occurrence.occurrences_between(Time.utc(2010, 1, 1, 9, 30), Time.utc(2010, 1, 4, 9, 30)).should == expected[0..2]

    # limit cases
    @occurrence.occurrences_between(@start_time, Time.utc(2000, 1, 2, 9, 30)).first.should == @start_time
    @occurrence.occurrences_between(Time.utc(1990, 1, 1), Time.utc(2000, 1, 2, 9, 30)).first.should == @start_time
  end

  describe "finite rules" do
    before do
      @start_time = Time.utc(2000, 1, 1, 9, 30)
      @count_occurrence = Occurrence.new(Rule.daily.count(10), @start_time)
      @stop_occurrence = Occurrence.new(Rule.daily.stop(Time.utc(2000, 1, 15, 10)), @start_time)
    end

    it "should find all occurrences" do
      @count_occurrence.all.length.should == 10
      @stop_occurrence.all.length.should == 15
    end

    it "should limit occurrences between" do
      # whole interval
      @count_occurrence.occurrences_between(Time.utc(1990, 1, 1), Time.utc(2001, 1, 1)).length.should == 10
      @stop_occurrence.occurrences_between(Time.utc(1990, 1, 1), Time.utc(2001, 1, 1)).length.should == 15

      # stop in interval
      @count_occurrence.occurrences_between(Time.utc(1990, 1, 1), Time.utc(2000, 1, 5)).length.should == 4
      @stop_occurrence.occurrences_between(Time.utc(1990, 1, 1), Time.utc(2000, 1, 5)).length.should == 4

      # start in interval
      @count_occurrence.occurrences_between(Time.utc(2000, 1, 5), Time.utc(2001, 1, 1)).length.should == 6
      @stop_occurrence.occurrences_between(Time.utc(2000, 1, 5), Time.utc(2001, 1, 1)).length.should == 11
    end

    it "should limit next occurrences" do
      # before interval
      @count_occurrence.next_occurrences(5, Time.utc(1990, 1, 1)).length.should == 5
      @stop_occurrence.next_occurrences(5, Time.utc(1990, 1, 1)).length.should == 5

      # inside interval
      @count_occurrence.next_occurrences(5, Time.utc(2000, 1, 8)).length.should == 3
      @stop_occurrence.next_occurrences(5, Time.utc(2000, 1, 12)).length.should == 4
    end

    it "should limit previous occurrences" do
      # inside interval
      @count_occurrence.previous_occurrences(5, Time.utc(2000, 1, 4)).length.should == 3
      @stop_occurrence.previous_occurrences(5, Time.utc(2000, 1, 4)).length.should == 3

      # after interval
      occ = @count_occurrence.previous_occurrences(5, Time.utc(2001, 1, 1))
      occ.length.should == 5
      occ.last.should == Time.utc(2000, 1, 10, 9, 30)

      occ = @stop_occurrence.previous_occurrences(5, Time.utc(2001, 1, 1))
      occ.length.should == 5
      occ.last.should == Time.utc(2000, 1, 15, 9, 30)
    end
  end

  describe "filtered rules" do
    before do
      @start_time = Time.utc(2000, 1, 1, 9, 30)
      @weekday_filtered_occurrence = Occurrence.new(Rule.daily.weekdays(:sat, :mon), @start_time)
      @month_filtered_occurrence = Occurrence.new(Rule.daily.months(:january, :sept), @start_time)
    end

    it "should filter next occurrences" do
      expected = [1, 3, 8, 10, 15, 17, 22].map { |i| Time.utc(2000, 1, i, 9, 30) }
      @weekday_filtered_occurrence.next_occurrences(7, Time.utc(2000, 1, 1, 2)).should == expected

      expected = [30, 31].map { |i| Time.utc(2000, 1, i, 9, 30) } +
                 (1..5).map { |i| Time.utc(2000, 9, i, 9, 30) }
      @month_filtered_occurrence.next_occurrences(7, Time.utc(2000, 1, 30)).should == expected
    end

    it "should filter previous occurrences" do
      expected = [1, 3, 8, 10, 15, 17, 22].map { |i| Time.utc(2000, 1, i, 9, 30) }
      @weekday_filtered_occurrence.previous_occurrences(7, Time.utc(2000, 1, 22, 10)).should == expected

      expected = [30, 31].map { |i| Time.utc(2000, 1, i, 9, 30) } +
                 (1..5).map { |i| Time.utc(2000, 9, i, 9, 30) }
      @month_filtered_occurrence.previous_occurrences(7, Time.utc(2000, 9, 6)).should == expected
    end

    it "should shift bad start time forward" do
      start_time = Time.utc(2000, 1, 1, 10, 0, 0)
      occurrence = Occurrence.new(Rule.yearly.months(3, 5).weekday(:monday), start_time)

      occurrence.start_time.should_not == start_time
      occurrence.start_time.should == Time.utc(2000, 3, 6, 10)
    end
  end

  describe "suboccurrences" do
    before do
      @start_time = Time.utc(2000, 1, 1, 9, 30)
      @occurrence = Occurrence.new(Rule.daily(3).count(10), @start_time)
      @occurrence.duration = 24.hours
    end

    it "should report duration" do
      @occurrence.duration.should == 24.hours
    end

    it "should find subooccurrences between dates" do
      s = @occurrence.suboccurrences_between(Time.utc(2000, 1, 1, 12), Time.utc(2000, 1, 5, 6))

      s.length.should == 2
      s.first.start.should == Time.utc(2000, 1, 1, 12)
      s.first.end.should == Time.utc(2000, 1, 2, 9, 30)

      s[1].start.should == Time.utc(2000, 1, 4, 9, 30)
      s[1].end.should == Time.utc(2000, 1, 5, 6)
    end
  end
end
