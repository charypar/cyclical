require 'spec_helper'

describe  do
  before do
    @filter = YeardaysFilter.new(1, 50, -50)
  end

  it "should accept weekdays as constructor arguments" do
    @filter.yeardays.should == [-50, 1, 50]
  end


  it "should match only the selected monthdays" do
    filter = YeardaysFilter.new(1, 100, 200, -10)

    filter.match?(Time.utc(2000, 1, 1)).should be_true
    filter.match?(Time.utc(2000, 4, 9)).should be_true
    filter.match?(Time.utc(2000, 7, 18)).should be_true
    filter.match?(Time.utc(2000, 12, 22)).should be_true

    filter.match?(Time.utc(2000, 2, 26)).should be_false

    filter.match?(Time.utc(2000, 1, 2)).should be_false
    filter.match?(Time.utc(2000, 4, 4)).should be_false
    filter.match?(Time.utc(2000, 8, 5)).should be_false
    filter.match?(Time.utc(2000, 11, 6)).should be_false
    filter.match?(Time.utc(2000, 11, 8)).should be_false
    filter.match?(Time.utc(2000, 12, 27)).should be_false
  end

  it "should provide next valid date" do
    @filter.next(Time.utc(2010, 1, 1, 21, 13, 11)).should == Time.utc(2010, 1, 1, 21, 13, 11)
    @filter.next(Time.utc(2010, 1, 2, 21, 13, 11)).should == Time.utc(2010, 2, 19, 21, 13, 11)
    @filter.next(Time.utc(2010, 2, 30, 21, 13, 11)).should == Time.utc(2010, 11, 12, 21, 13, 11)
  end
end
