require 'spec_helper'

describe DirValidator::Validator do

  before(:each) do
    @fdir = fixture_item(:basic)
    @dv   = DirValidator::Validator.new(@fdir)
  end

  it "can initialize a validator" do
    @dv.should         be_kind_of DirValidator::Validator
    @dv.catalog.should be_kind_of DirValidator::Catalog
  end

  describe "process_items()" do

    before(:each) do
      paths = %q()
      @items = paths.each { |p| DirValidator::Item.new(nil, p) }
    end

    it "validation methods should make appropriate calls to process_items()" do
    end

    it "should work..." do
    end

  end

  
  ####
  # name_filtered()
  ####

  describe "name_filtered()" do

    before(:each) do
      @paths = %w(
        a
        b
        bar/
        bar/a
        bar/b
        bar/xx/
        bar/xx/a
        bar/xx/b
        foo/
        foo/a
        foo/b
        foo/xx/
        foo/xx/c
        foo/xx/d
        foo/xyy/
        foo/xyy/a
        foo/xyy/b
        fubb/
        fubb/a
        fubb/b
      )
      @items = p2i(@paths)
    end

    describe "base_dir and recurse interaction" do

      it "should behave correctly with w/wo base_dir, w/wo recurse" do
        common_opts = {}
        tests = [
          [ {}, %w(a b bar foo fubb) ],
          [ {:base_dir => 'foo'}, %w(foo/a foo/b foo/xx foo/xyy) ],
          [ {:recurse => true}, @paths ],
          [ {:recurse => true, :base_dir => 'foo'}, @paths.select { |p| p =~ /\Afoo./ } ],
        ]
        tests.each do |opts, exp|
          nf = @dv.name_filtered(@items, common_opts.merge(opts))
          i2p(nf).should == exp
        end
      end

    end

    describe "setting Item.target values" do

      it "base_dir = nil: targets should be the same as paths" do
        opts = {}
        nf   = @dv.name_filtered(@items, opts)
        nf.each { |i| i.target.should == i.path }
      end

      it "base_dir = yes: targets should be the path without the base_dir" do
        opts = {:base_dir => 'foo'}
        nf   = @dv.name_filtered(@items, opts)
        nf.map { |i| i.target }.should == %w(a b xx xyy)
      end

    end

    describe ":name" do

      it "should behave correctly with various patterns, w/wo base_dir" do
        common_opts = {}
        tests = [
          [ {:name => 'foo'}, %w(foo) ],
          [ {:name => 'a', :base_dir => 'foo'}, %w(foo/a) ],
          [ {:name => 'qqq'}, %w() ],
        ]
        tests.each do |opts, exp|
          nf = @dv.name_filtered(@items, common_opts.merge(opts))
          i2p(nf).should == exp
        end
      end

    end

    describe ":pattern, recurse = false" do

      it "should behave correctly with various patterns, w/wo base_dir" do
        common_opts = {}
        tests = [
          [ {:pattern => 'f*'},  %w(foo fubb) ],
          [ {:pattern => 'x*', :base_dir => 'foo'},  %w(foo/xx foo/xyy) ],
        ]
        tests.each do |opts, exp|
          nf = @dv.name_filtered(@items, common_opts.merge(opts))
          i2p(nf).should == exp
        end
      end

    end

    describe ":pattern, recurse = true" do

      it "should behave correctly with various patterns, w/wo base_dir" do
        common_opts = {:recurse => true}
        tests = [
          [ {:pattern => 'f*'},     @paths.select { |p| p =~ /\Af/ } ],
          [ {:pattern => 'f*/x??'}, %w(foo/xyy) ],
          [ {:pattern => 'f*/xy*'}, %w(foo/xyy foo/xyy/a foo/xyy/b) ],
          [ {:pattern => 'x*',  :base_dir => 'foo'}, @paths.select { |p| p =~ /\Afoo\/x/ } ],
          [ {:pattern => '*/*', :base_dir => 'foo'}, %w(foo/xx/c foo/xx/d foo/xyy/a foo/xyy/b) ],
        ]
        tests.each do |opts, exp|
          nf = @dv.name_filtered(@items, common_opts.merge(opts))
          i2p(nf).should == exp
        end
      end

    end

    describe ":re" do

      it "should behave correctly w/wo base_dir, w/wo recurse" do
        common_opts = {:re => '.*a.*'}
        tests = [
          [ {}, %w(a bar) ],
          [ {:base_dir => 'foo'}, %w(foo/a) ],
          [ {:recurse => true}, @paths.select { |p| p =~ /a/ } ],
          [ {:recurse => true, :base_dir => 'foo'}, %w(foo/a foo/xyy/a) ],
        ]
        tests.each do |opts, exp|
          nf = @dv.name_filtered(@items, common_opts.merge(opts))
          i2p(nf).should == exp
        end
      end

    end

  end


  ####
  # normalized_base_dir()
  ####

  describe "normalized_base_dir()" do

    it "should return empty string if :base_dir is not among the validation options" do
      @dv.normalized_base_dir({}).should == ''
    end

    it "should return path with a trailing separator" do
      tests = [
        ['foo/bar',  'foo/bar/'],
        ['foo/bar/', 'foo/bar/'],
        ['.',        './'],
      ]
      tests.each do |bd, exp|
        @dv.normalized_base_dir({:base_dir => bd}).should == exp
      end
    end

  end


  ####
  # name_regex() etc
  ####

  describe "name_regex() and related methods" do

    it "conditional logic of name_regex() should work as expected" do
      n = 'foo'
      p = 'foo.*'
      r = 'f.*\.txt'
      opts = {:name => n, :pattern => p, :re => r}
      @dv.name_regex(opts).should == Regexp.new(@dv.name_to_re(n))
      opts.delete(:name)
      @dv.name_regex(opts).should == Regexp.new(@dv.pattern_to_re(p))
      opts.delete(:pattern)
      @dv.name_regex(opts).should == Regexp.new(r)
    end

    it "can exercise name_to_re()" do
      s = 'a-b.txt'
      @dv.name_to_re(s).should == '\\Aa\\-b\\.txt\\z'
    end

    it "can exercise pattern_to_re()" do
      tests = [
        # Basic glob characters.
        [ '*', '.*' ],
        [ '?', '.' ],
        # Both basic glob characters and special Regexp characters.
        [ 'f.b.*/b-b/f?/*.t', 'f\\.b\\..*/b\-b/f./.*\.t' ],
      ]
      tests.each do |s, exp|
        @dv.pattern_to_re(s).should == @dv.az_wrap(exp)
      end
    end

    it "can exercise az_wrap()" do
      s = 'foo'
      @dv.az_wrap(s).should == ['\A', '\z'].join(s)
    end

  end


  ####
  # Other methods.
  ####

  it "quantity_limited() works correctly" do
    items = (0..10).to_a
    specs = ['1+', '3', '3-5', '14']
    qs    = specs.map { |s| DirValidator::Quantity.new(s) }
    exp   = [-1, 2, 4, -1]
    qs.zip(exp).each do |q, e|
      @dv.quantity_limited(items, q).should == items[0..e]
    end
  end

  it "can exercise add_warning()" do
    @dv.warnings.size.should == 0
    @dv.add_warning('foo', 'blah')
    @dv.add_warning('foo', 'blah')
    @dv.warnings.size.should == 2
    @dv.warnings.first.should be_kind_of DirValidator::Warning
  end

  it "validate() should add warning for each unmatched Item, and should run once" do
    mock_items = (1..4).map { |n| double('item', :path => "path_#{n}") }
    @dv.catalog.should_receive(:unmatched_items).once.and_return(mock_items)
    # First call should add the warnings.
    @dv.validated.should == false
    @dv.validate
    @dv.warnings.size.should == mock_items.size
    @dv.validated.should == true
    # Subsequent calls should do nothing.
    @dv.validate
    @dv.warnings.size.should == mock_items.size
    @dv.validated.should == true
  end

end
