require 'spec_helper'

describe DirValidator::Item do

  def new_item(path, catalog_id = nil)
    return DirValidator::Item.new(nil, path, catalog_id)
  end

  it "can initialize a Item" do
    new_item('.').should be_kind_of DirValidator::Item
  end

  it "should have set path-related attributes correctly" do
    itm = new_item('./foo/bar/fubb/../.././blah.txt')
    ivget(itm, :pathname).should be_kind_of Pathname
    itm.path.should == 'foo/blah.txt'  # Path should be normalized.
    itm.basename.should == 'blah.txt'  # Can get basename.
  end

  it "should set dirname and dirname2 correctly" do
    # If there is a parent dir, dirname and dirname2 should agree.
    itm = new_item('foo/blah.txt')
    itm.dirname.should == 'foo'
    itm.dirname2.should == 'foo'
    # If no parent dir, they will differ.
    itm = new_item('blah.txt')
    itm.dirname.should == '.'
    itm.dirname2.should == ''
  end

  it "should set catalog_id if given, otherwise nil" do
    new_item('foo').catalog_id.should == nil
    new_item('foo', 987).catalog_id.should == 987
  end

  it "should set filetype-related attributes correctly" do
    # A dir.
    itm = new_item(Tempfile.new('item_spec_').path)
    itm.filetype.should    == :file
    itm.is_file.should == true
    itm.is_dir.should  == false
    # A dir.
    itm = new_item('.')
    itm.filetype.should    == :dir
    itm.is_file.should == false
    itm.is_dir.should  == true
  end

  it "basename() should support a suffix argument" do
    itm = new_item('foo/bar.rb')
    itm.basename.should == 'bar.rb'
    itm.basename('.rb').should == 'bar'
  end

  describe "target_match()" do

    it "should return MatchData and store it for later use" do
      itm = new_item('.')
      itm.set_target('aabb')
      m = itm.target_match(/(a+)(b+)/)
      m[0].should == 'aabb'
      m[1].should == 'aa'
      itm.match_data.should be_kind_of MatchData
      itm.match_data[2].should == 'bb'
    end

    it "should return nil if the match fails" do
      itm = new_item('.')
      itm.set_target('zzzz')
      m = itm.target_match(/a/)
      m.should == nil
      itm.match_data.should == nil
    end

  end

  describe "can call validation methods on Item objects" do

    before(:each) do
      # Setup params for the double and stubbed method.
      @dv   = double('dir_validator')
      @path = '.'
      @vid  = 'foo-validation'
      @opts = {:a => 1, :b => 2}
      @exp  = [1,2,3]
    end

    it "dirs()" do
      hi = hash_including(:base_dir => @path)
      @dv.should_receive(:dirs).with(@vid, hi).and_return(@exp)
      DirValidator::Item.new(@dv, @path).dirs(@vid, @opts).should == @exp
    end

    it "files()" do
      hi = hash_including(:base_dir => @path)
      @dv.should_receive(:files).with(@vid, hi).and_return(@exp)
      DirValidator::Item.new(@dv, @path).files(@vid, @opts).should == @exp
    end

    it "dir()" do
      hi = hash_including(:base_dir => @path)
      @dv.should_receive(:dir).with(@vid, hi).and_return(@exp)
      DirValidator::Item.new(@dv, @path).dir(@vid, @opts).should == @exp
    end

    it "file()" do
      hi = hash_including(:base_dir => @path)
      @dv.should_receive(:file).with(@vid, hi).and_return(@exp)
      DirValidator::Item.new(@dv, @path).file(@vid, @opts).should == @exp
    end

  end

  describe "item_opts() should return expected hash" do

    before(:each) do
      @opts = {:aaa => 111, :bbb => 222}
    end

    it "directory: base_dir = Item.path" do
      itm = new_item('foo/bar')
      ivset(itm, :filetype, :dir)
      exp = {:base_dir => itm.path}
      itm.item_opts(@opts).should == @opts.merge(exp)
    end

    it "file with a parent dir: base_dir = Item.dirname" do
      itm = new_item('foo/bar.txt')
      ivset(itm, :filetype, :file)
      exp = {:base_dir => 'foo'}
      itm.item_opts(@opts).should == @opts.merge(exp)
    end

    it "file without a parent dir: no base_dir" do
      itm = new_item('bar.txt')
      ivset(itm, :filetype, :file)
      itm.item_opts(@opts).should == @opts
    end

  end

  it "mark_as_matched() should work" do
    itm = new_item('bar.txt')
    itm.matched.should == false
    itm.mark_as_matched
    itm.matched.should == true
  end

  it "set_target() should work" do
    itm = new_item('bar.txt')
    itm.target.should == nil
    exp = 'blah'
    itm.set_target(exp)
    itm.target.should == exp
  end

end
