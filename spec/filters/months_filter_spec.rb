require 'spec_helper'

describe MonthsFilter do
  before do
    @filter = MonthsFilter.new(:january, :feb, 3)
  end

  it "should accept months as constructor arguments" do
    @filter.months.should == [1, 2, 3]
  end

  it "should provide next valid date" do
    @filter.next(Time.utc(2009, 5, 10, 21, 13, 11)).should == Time.utc(2010, 1, 1, 21, 13, 11)
    @filter.next(Time.utc(2009, 12, 10, 21, 13, 11)).should == Time.utc(2010, 1, 1, 21, 13, 11)
    @filter.next(Time.utc(2010, 1, 10, 21, 13, 11)).should == Time.utc(2010, 1, 10, 21, 13, 11)
    @filter.next(Time.utc(2010, 2, 14, 21, 13, 11)).should == Time.utc(2010, 2, 14, 21, 13, 11)
    @filter.next(Time.utc(2010, 3, 14, 21, 13, 11)).should == Time.utc(2010, 3, 14, 21, 13, 11)
  end
end
