require 'spec_helper'

describe Suboccurrence do
  it "should create occurrence through factory method" do
    i1 = Time.now..(Time.now + 1.hour)
    i2 = (Time.now - 1.hour)..(Time.now + 2.hours)

    Suboccurrence.find(:occurrence => i1, :interval => i2).should be_a(Suboccurrence)
  end

  it "should return nil when there no intersection" do
    t = Time.now
    s = Suboccurrence.find(:occurrence => t..(t+1.minute), :interval => (t+1.minute)..(t+2.minutes))
    s.should be_nil

    s = Suboccurrence.find(:occurrence => (t+1.minute)..(t+2.minutes), :interval => t..(t+1.minutes))
    s.should be_nil
  end

  it "should return the later of the two starts" do
    t = Time.now

    s = Suboccurrence.find(:occurrence => t..(t+1.hour), :interval => (t+2.minutes)..(t+2.hours))
    s.start.should == t+2.minutes

    s = Suboccurrence.find(:occurrence => (t+2.minutes)..(t+2.hours), :interval => t..(t+1.hour))
    s.start.should == t+2.minutes
  end

  it "should return the sooner of the two ends" do
    t = Time.now

    s = Suboccurrence.find(:occurrence => t..(t+1.hour), :interval => (t+2.minutes)..(t+2.hours))
    s.end.should == t+1.hour

    s = Suboccurrence.find(:occurrence => (t+2.minutes)..(t+2.hours), :interval => t..(t+1.hour))
    s.end.should == t+1.hour
  end

  it "should report cutoffs" do
    t = Time.now

    s = Suboccurrence.find(:occurrence => t..(t+1.hour), :interval => (t+2.minutes)..(t+2.hours))
    s.occurrence_start?.should_not be_true
    s.occurrence_end?.should be_true

    s = Suboccurrence.find(:occurrence => (t+2.minutes)..(t+2.hours), :interval => t..(t+1.hour))
    s.occurrence_start?.should be_true
    s.occurrence_end?.should_not be_true
  end
end
