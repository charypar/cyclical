require 'spec_helper'

describe  do
  before do
    @filter = MonthdaysFilter.new(1, 3, -5)
  end

  it "should accept weekdays as constructor arguments" do
    @filter.monthdays.should == [-5, 1, 3]
  end


  it "should match only the selected monthdays" do
    filter = MonthdaysFilter.new(1, 3, 17, -6)

    filter.match?(Time.utc(2000, 1, 1)).should be_true
    filter.match?(Time.utc(2000, 1, 3)).should be_true
    filter.match?(Time.utc(2000, 1, 17)).should be_true
    filter.match?(Time.utc(2000, 1, 26)).should be_true

    filter.match?(Time.utc(2000, 2, 26)).should be_false

    filter.match?(Time.utc(2000, 1, 2)).should be_false
    filter.match?(Time.utc(2000, 1, 4)).should be_false
    filter.match?(Time.utc(2000, 1, 5)).should be_false
    filter.match?(Time.utc(2000, 1, 6)).should be_false
    filter.match?(Time.utc(2000, 1, 8)).should be_false
    filter.match?(Time.utc(2000, 1, 27)).should be_false
  end

  it "should provide next valid date" do
    @filter.next(Time.utc(2010, 1, 1, 21, 13, 11)).should == Time.utc(2010, 1, 1, 21, 13, 11)
    @filter.next(Time.utc(2010, 1, 2, 21, 13, 11)).should == Time.utc(2010, 1, 3, 21, 13, 11)
    @filter.next(Time.utc(2010, 1, 18, 21, 13, 11)).should == Time.utc(2010, 1, 27, 21, 13, 11)
  end
end
