require 'spec_helper'

describe("Integration tests: preliminary...", :integration => true) do

  before(:each) do
    @fdir = fixture_item(:basic)
    @dv   = DirValidator.new(@fdir)
  end

  it "1" do
    ds = @dv.dirs('top-level', :re => 'a')
    i2p(ds).should == %w(aa ab ba)
  end

  it "2" do
    ds = @dv.dirs('top-level', :re => 'a', :recurse => true)
    i2p(ds).should == %w(
      aa aa/bar aa/foo
      ab ab/bar ab/foo
      ba ba/bar ba/foo
      bb/bar)
  end

  it "3" do
    ds = @dv.files('top-level', :pattern => 'aa/*.txt', :recurse => true)
    i2p(ds).should == [
      "aa/bar/01.txt",
      "aa/bar/02.txt",
      "aa/bar/03.txt",
      "aa/foo/01.txt",
      "aa/foo/02.txt",
      "aa/foo/03.txt"]
  end

end
