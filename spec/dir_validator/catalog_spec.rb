describe DirValidator::Catalog do

  before(:each) do
    @cat  = DirValidator::Catalog.new(nil)
    @mock_items = [
      # Dirs.
      double('item', :is_dir => true,  :is_file => false, :matched => true),
      double('item', :is_dir => true,  :is_file => false, :matched => true),
      double('item', :is_dir => true,  :is_file => false, :matched => false),
      # Files.
      double('item', :is_dir => false, :is_file => true,  :matched => true),
      double('item', :is_dir => false, :is_file => true,  :matched => false),
      double('item', :is_dir => false, :is_file => true,  :matched => false),
      double('item', :is_dir => false, :is_file => true,  :matched => false),
      double('item', :is_dir => false, :is_file => true,  :matched => false),
    ]
  end

  it "can initialize a Catalog" do
    @cat.should be_kind_of DirValidator::Catalog
  end

  it "items() should call load_items() only once" do
    # Stub out the load_items() method.
    exp = 'foobar!!!'
    @cat.should_receive(:load_items).once.and_return(exp)
    # Initally, @items should be nil.
    @cat.instance_variable_get('@items').should == nil
    # First call of items() should invoke load_items().
    @cat.items.should == exp
    @cat.instance_variable_get('@items').should == exp
    # Subsequent calls should return @items directly.
    @cat.items.should == exp
    @cat.items.should == exp
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

  it "can exercise dirs()" do
    @cat.stub(:items).and_return(@mock_items)
    @cat.dirs.size.should == 3
  end

  it "can exercise files()" do
    @cat.stub(:items).and_return(@mock_items)
    @cat.files.size.should == 5
  end

  it "can exercise unmatched_items()" do
    @cat.stub(:items).and_return(@mock_items)
    @cat.unmatched_items.size.should == 5
  end

  it "can exercise unmatched_dirs()" do
    @cat.stub(:items).and_return(@mock_items)
    @cat.unmatched_dirs.size.should == 1
  end

  it "can exercise unmatched_files()" do
    @cat.stub(:items).and_return(@mock_items)
    @cat.unmatched_files.size.should == 4
  end

end
