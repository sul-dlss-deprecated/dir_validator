require 'spec_helper'

describe DirValidator::Catalog do

  before(:each) do
    @cat  = DirValidator::Catalog.new(nil)
    mock_params = [
      # Dirs.
      { :is_dir => true,   :matched => true },
      { :is_dir => true,   :matched => true },
      { :is_dir => true,   :matched => false },
      # Files.
      { :is_dir => false,  :matched => true },
      { :is_dir => false,  :matched => false },
      { :is_dir => false,  :matched => false },
      { :is_dir => false,  :matched => false },
      { :is_dir => false,  :matched => false },
    ]
    @mock_items = mock_params.each_with_index.map { |ps, i|
      double('item', ps.merge(:is_file => ! ps[:is_dir], :catalog_id => i))
    }
    @mock_unmatched = {}
    @mock_items.each { |i| @mock_unmatched[i.catalog_id] = true unless i.matched  }
    @cat.instance_variable_set('@unmatched', @mock_unmatched)
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

  it "can exercise unmatched_items()" do
    @cat.stub(:items).and_return(@mock_items)
    @cat.unmatched_items.size.should == 5
  end

  it "qqq can exercise unmatched_dirs()" do
    @cat.stub(:items).and_return(@mock_items)
    @cat.unmatched_dirs.size.should == 1
  end

  it "can exercise unmatched_files()" do
    @cat.stub(:items).and_return(@mock_items)
    @cat.unmatched_files.size.should == 4
  end

  it "mark_as_matched() should set Item.matched = true and prune the @unmatched hash" do
    mock_paths = %w(a b bar/ bar/a bar/b)
    sz = mock_paths.size
    mock_unmatched = Hash[ (0 .. sz).map { |n| [n,true] } ]
    @cat.stub(:items).and_return(p2i(mock_paths))
    @cat.instance_variable_set('@unmatched', mock_unmatched)
    @cat.items.all? { |i| i.matched == false }.should be_true
    @cat.mark_as_matched(@cat.items)
    @cat.items.all? { |i| i.matched == true  }.should be_true
    @cat.instance_variable_get('@unmatched').should == { sz => true }
  end

end
