require 'spec_helper'

describe DirValidator::Warning do

  before(:each) do
    @vid  = 'foo'
    @opts = {:a => 111, :b => 222}
    @w    = DirValidator::Warning.new(@vid, @opts)
  end

  it "can initialize a Warning" do
    @w.should be_kind_of DirValidator::Warning
    @w.vid.should == @vid
    @w.opts.should == @opts
  end

  it "can exercise to_s()" do
    s = @w.to_s
    s.should be_instance_of String
    s.size.should > 0
  end

end
