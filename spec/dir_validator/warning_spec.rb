describe DirValidator::Warning do

  before(:each) do
    @vid     = 'foo'
    @message = 'blah blah'
    @w       = DirValidator::Warning.new(@vid, @message)
  end

  it "can initialize a Warning" do
    @w.should be_kind_of DirValidator::Warning
    @w.vid.should == @vid
  end

  it "can exercise to_s()" do
    @w.to_s.should =~ Regexp.new(@message)
  end

end
