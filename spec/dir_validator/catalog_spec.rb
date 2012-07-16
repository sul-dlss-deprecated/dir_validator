require 'spec_helper'

describe DirValidator::Catalog do

  before(:each) do
    # A Catalog.
    @cat  = DirValidator::Catalog.new(nil)
    # Some mock Items to put in the Catalog.
    mock_params = [
      # Dirs.
      { :is_dir => true,   :matched => true },  # 0
      { :is_dir => true,   :matched => true },  # 1
      { :is_dir => true,   :matched => false }, # 2
      # Files.
      { :is_dir => false,  :matched => true },  # 3
      { :is_dir => false,  :matched => false }, # 4
      { :is_dir => false,  :matched => false }, # 5
      { :is_dir => false,  :matched => false }, # 6
      { :is_dir => false,  :matched => false }, # 7
      # More dirs.
      { :is_dir => true,   :matched => false }, # 8
      { :is_dir => true,   :matched => false }, # 9
    ]
    @mock_dirname2 = 'blah'
    @mock_items = mock_params.each_with_index.map { |ps, i|
      double_params = ps.merge(
        :dirname2   => @mock_dirname2,
        :is_file    => ! ps[:is_dir],
        :catalog_id => i)
      double('item', double_params)
    }
    # Set up some mock indexes.
    @mock_unmatched = {}
    @mock_bdi       = {'even' => {}, 'odd' => {}}
    @mock_items.each_with_index do |item, i|
      next if item.matched
      cid = item.catalog_id
      @mock_unmatched[cid] = true
      @mock_bdi[i % 2 == 0 ? 'even' : 'odd'][cid] = true
    end
  end

  it "can initialize a Catalog" do
    @cat.should be_kind_of DirValidator::Catalog
  end

  describe "getting Items" do

    it "items() should call load_items() only once" do
      # Stub out the load_items() method.
      exp = 'foobar!!!'
      @cat.should_receive(:load_items).once.and_return(exp)
      # Initally, @items should be nil.
      ivget(@cat, :items).should == nil
      # First call of items() should invoke load_items().
      @cat.items.should == exp
      ivget(@cat, :items).should == exp
      # Subsequent calls should return @items directly.
      @cat.items.should == exp
      @cat.items.should == exp
    end

    it "can exercise load_items() on the lib/ dir and get expected N of items" do
      # Also see integration tests.
      root = 'lib'
      mock_validator = double('validator', :root_path => root)
      exp = Dir.glob("#{root}/**/*")
      ivset(@cat, :validator, mock_validator)
      ivget(@cat, :items).should == nil
      @cat.load_items
      ivget(@cat, :items).size.should == exp.size
    end
    
  end

  it "path_is_dot_dir() should behave correctly" do
    tests = [
      [true,  '.'],
      [true,  '..'],
      [true,  '/.'],
      [true,  '/..'],
      [true,  'foo/.'],
      [true,  'foo/..'],
      [false, '...'],
      [false, '/...'],
      [false, 'foo/...'],
      [false, './foo'],
      [false, '../foo'],
      [false, '/./foo'],
      [false, '/../foo'],
      [false, 'foo/./foo'],
      [false, 'foo/../foo'],
    ]
    tests.each_with_index do |(exp, path), i|
      path   = path.gsub('\/', File::SEPARATOR)  # Use the OS file spearator.
      result = @cat.path_is_dot_dir(path)
      [i, result].should == [i, exp]
    end
  end

  describe "unmatched_items(), _dirs(), and _files()" do

    before(:each) do
      ivset(@cat, :unmatched, @mock_unmatched)
      ivset(@cat, :bdi, @mock_bdi)
      @cat.stub(:items).and_return(@mock_items)
    end

    it "without a base_dir: should return all unmatched Items" do
      @cat.unmatched_items.size.should == 7
      @cat.unmatched_dirs.size.should  == 3
      @cat.unmatched_files.size.should == 4
    end

    it "without a base_dir: should return unmatched Items having correct base_dir" do
      # base_dir = 'odd'
      @cat.unmatched_items('odd').size.should  == 3
      @cat.unmatched_files('odd').size.should  == 2
      @cat.unmatched_dirs('odd').size.should   == 1
      # base_dir = 'even'
      @cat.unmatched_items('even').size.should == 4
      @cat.unmatched_files('even').size.should == 2
      @cat.unmatched_dirs('even').size.should  == 2
    end

  end

  it "mark_as_matched() should set Item.matched = true and invoke delete_from_index()" do
    mock_paths = %w(a b bar/ bar/a bar/b)
    @cat.stub(:items).and_return(p2i(mock_paths))
    @cat.should_receive(:delete_from_index).exactly(mock_paths.size).times
    @cat.items.all? { |i| i.matched == false }.should be_true
    @cat.mark_as_matched(@cat.items)
    @cat.items.all? { |i| i.matched == true  }.should be_true
  end

  it "add_to_index() and delete_from_index() should modify @unmatched and @bdi" do
    ns  = (0...@mock_items.size).to_a
    exp = Hash[ ns.map { |n| [n,true] } ]
    bdi = ivget(@cat, :bdi)
    unm = ivget(@cat, :unmatched)
    bdi.should == {}
    unm.should == {}
    # add_to_index()
    @mock_items.each { |i| @cat.add_to_index(i) }
    bdi.should == { @mock_dirname2 => exp }
    unm.should == exp
    # delete_from_index() the Items with odd indices
    ns.each do |n|
      next if n % 2 == 0
      @cat.delete_from_index(@mock_items[n])
      exp.delete(n)
    end
    bdi.should == { @mock_dirname2 => exp }
    unm.should == exp
    # delete_from_index() the remaining Items.
    ns.each do |n|
      next if n % 2 == 1
      @cat.delete_from_index(@mock_items[n])
      exp.delete(n)
    end
    bdi.should == { @mock_dirname2 => exp }
    unm.should == exp
  end

end
