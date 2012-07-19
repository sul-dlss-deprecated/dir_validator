require 'spec_helper'

describe DirValidator::Validator do

  before(:each) do
    @dv = DirValidator::Validator.new('.')
    @mock_paths = %w(
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
  end

  it "can initialize a validator" do
    @dv.should         be_kind_of DirValidator::Validator
    @dv.catalog.should be_kind_of DirValidator::Catalog
  end


  ####
  # Validation methods: dirs(), dir(), files(), file().
  ####

  describe "user-facing validation methods: dirs(), dir(), files(), file()" do

    before(:each) do
      @items = p2i(@mock_paths)
      @vid   = 'test'
      @dv.catalog.stub(:delete_from_index)
    end

    it "can exercise the methods" do
      opts = {:recurse => true}
      ds = @items.select { |i| i.is_dir  }
      fs = @items.select { |i| i.is_file }
      @dv.catalog.stub(:unmatched_dirs).and_return(ds)
      @dv.catalog.stub(:unmatched_files).and_return(fs)
      @dv.dirs(@vid,  opts).should == ds
      @dv.files(@vid, opts).should == fs
      @dv.dir(@vid,   opts).should == [ds.first]
      @dv.file(@vid,  opts).should == [fs.first]
    end

  end

  describe "process_items()" do

    before(:each) do
      @items      = p2i(@mock_paths)
      @vid        = 'test'
      @root_paths = @mock_paths.reject { |i| i =~ /\// }
      @dv.catalog.stub(:mark_as_matched)
    end

    it "should raise ArgumentError if user forgets to pass validation identifier" do
      expect { @dv.process_items([], {}) }.to raise_error ArgumentError, /not be a hash/
    end

    it "should return all items if there is no quantity limit" do
      i2p(@dv.process_items(@items, @vid, {})).should == @root_paths
    end

    it "should return return no more than the max quantity" do
      @dv.catalog.stub(:delete_from_index)
      @dv.process_items(@items, @vid, {:n => '0-3'}).size.should == 3
      @dv.process_items(@items, @vid, {:n => '2'}).size.should == 2
      @dv.process_items(@items, @vid, {:n => '1-99'}).size.should == @root_paths.size
    end

    it "should add a warning if the N of items found is less than the min quantity" do
      @dv.warnings.size.should == 0
      # Will return enough: no warning.
      n = @root_paths.size
      @dv.process_items(@items, @vid, {:n => n.to_s})
      @dv.warnings.size.should == 0
      # Will return too few: warning.
      n += 1
      @dv.process_items(@items, @vid, {:n => n.to_s})
      @dv.warnings.size.should == 1
      # Check the warning.
      w = @dv.warnings.first
      w.opts[:got].should == n - 1
      w.opts[:n].should == n.to_s
    end

  end

  ####
  # name_filtered()
  ####

  describe "name_filtered()" do

    before(:each) do
      @items = p2i(@mock_paths)
    end

    describe "base_dir and recurse interaction" do

      it "should behave correctly with w/wo base_dir, w/wo recurse" do
        common_opts = {}
        tests = [
          [ {}, %w(a b bar foo fubb) ],
          [ {:base_dir => 'foo'}, %w(foo/a foo/b foo/xx foo/xyy) ],
          [ {:recurse => true}, @mock_paths ],
          [ {:recurse => true, :base_dir => 'foo'}, @mock_paths.select { |p| p =~ /\Afoo./ } ],
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
          [ {:pattern => 'f*'},     @mock_paths.select { |p| p =~ /\Af/ } ],
          [ {:pattern => 'f*/x??'}, %w(foo/xyy) ],
          [ {:pattern => 'f*/xy*'}, %w(foo/xyy foo/xyy/a foo/xyy/b) ],
          [ {:pattern => 'x*',  :base_dir => 'foo'}, @mock_paths.select { |p| p =~ /\Afoo\/x/ } ],
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
          [ {:recurse => true}, @mock_paths.select { |p| p =~ /a/ } ],
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

    it "should return nil if we are handling the :recurse option" do
      # Normal behavior.
      opts = {:base_dir => 'foo//'}
      @dv.normalized_base_dir(opts).should == 'foo'
      # Still normal behavior, even though :recurse => true.
      opts.merge!(:recurse => true)
      @dv.normalized_base_dir(opts).should == 'foo'
      # Now return nil.
      @dv.normalized_base_dir(opts, :handle_recurse => true).should == nil
    end

    it "should return '' if :base_dir is not among the validation options" do
      @dv.normalized_base_dir({}).should == ''
    end

    it "should return path with a trailing separator if add_file_sep=true" do
      tests = [
        ['foo/bar',  'foo/bar/'],
        ['foo/bar/', 'foo/bar/'],
        ['.',        './'],
      ]
      tests.each do |bd, exp|
        @dv.normalized_base_dir({:base_dir => bd}, :add_file_sep => true).should == exp
      end
    end

    it "should return path without trailing separator if add_file_sep=false" do
      tests = [
        ['foo/bar',    'foo/bar'],
        ['foo/bar/',   'foo/bar'],
        ['foo/bar///', 'foo/bar'],
        ['.',          '.'],
        ['.////',      '.'],
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
  # Reporting.
  ####

  it "can exercise add_warning()" do
    @dv.warnings.size.should == 0
    @dv.add_warning('foo', 'blah')
    @dv.add_warning('foo', 'blah')
    @dv.warnings.size.should == 2
    @dv.warnings.first.should be_kind_of DirValidator::Warning
  end

  it "report_data() should return the expected array-of-arrays" do
    @dv.add_warning('foo', :n  => '*', :path => 222, :base_dir => 'xx')
    @dv.add_warning('bar', :re => 333, :pattern => 444, :got => 12, :name => 'yy')
    @dv.report_data.should == [@dv.report_columns] + [
      ['foo', '',  '*', 'xx', '',    '',  '',  222],
      ['bar', 12,  '',  '',   'yy',  333, 444, ''],
    ]
  end

  it "can exercise report()" do
    @dv.add_warning('foo', :n  => 111, :path => 222)
    @dv.add_warning('bar', :re => 333, :pattern => 444)
    ivset(@dv, :validated, true)
    sio = StringIO.new
    @dv.report(sio)
    %w(foo bar 111 222 333 444).each { |s| sio.string.should =~ Regexp.new(s) }
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

end
